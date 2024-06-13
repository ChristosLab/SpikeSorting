function output_folder = test_ks_params(rootZ, rootO, chanMapFile, ops_list, varargin)
%Edited Mar. 3rd 2023 from official KS2.5 main_kilosort
%%  backward compatible input parser
default_start_ops = 0;
p = inputParser;
addParameter(p,'start_ops', default_start_ops);
parse(p, varargin{:});
%%
addpath(genpath('Kilosort-main')) % path to kilosort folder
pathToYourConfigFile = pwd; % take from Github folder and put it somewhere else (together with the master_file)
ops.chanMap = fullfile(pathToYourConfigFile, chanMapFile);
load(ops.chanMap, 'chanMap');
ops.NchanTOT  = numel(chanMap); % total number of channels in your recording

%% this block runs all the steps of the algorithm
fprintf('Looking for data inside %s \n', rootZ)
for i_ops_list = p.Results.start_ops:numel(ops_list)
    current_output   = fullfile(rootO, num2str(i_ops_list));
    output_folder    = fullfile(current_output, 'kilosort3');
    current_ops_json = fullfile(current_output, 'ops.txt');
    current_ops_mat  = fullfile(current_output, 'ops.mat');
    run(fullfile(pathToYourConfigFile, 'configFile_default.m'))
    ops.NT           = round((ops.NT - ops.ntbuff) * (128/min(128, ops.NchanTOT))/32)*32 + ops.ntbuff;
    % find the binary file
    fs          = [dir(fullfile(rootZ, '*.bin')) dir(fullfile(rootZ, '*.dat'))];
    ops.fbinary = fullfile(rootZ, fs(1).name);
    %
    if ~isfolder(current_output)
        mkdir(current_output);
    end
    %   Update ops
    if i_ops_list > 0 % Use default ops on the 1st run
        disp(ops_list{i_ops_list})
        ops = update_ops(ops, ops_list{i_ops_list});
    end
    ops_match_flag = 0; %   Ensure potential existing results were generated w/ the same configuration
    if isfile(current_ops_mat)
        to_load = load(current_ops_mat, 'ops');
        ops_on_disk = to_load.ops;
        ops_match_flag = isequal(ops_on_disk, ops);
    end
    if ops_match_flag && isfile(fullfile(current_output, 'kilosort3', 'rez.mat')) %  If already sorted
        continue
    end
    fid_ = fopen(current_ops_json, 'w+');
    fwrite(fid_, jsonencode(ops));
    fclose(fid_);
    save(current_ops_mat, "ops");
    %   Proc file not re-calculated for ops in the list. Make sure no
    %   parameters used for whitening is changed.
    ops.fproc              = fullfile(rootO, 'temp_wh.dat'); % proc file on a fast SSD
    preproc_rez_dir        = fullfile(rootO, 'preproc_rez.mat'); % Intermediate datashift2 output
    %%
%     if ~isfile(preproc_rez_dir) || ~ops_match_flag % Do whitening once. Save Wrot and whitened data
    if ~isfile(preproc_rez_dir) % Do whitening once. Save Wrot and whitened data
        rez                = preprocessDataSub(ops);
        rez                = datashift2(rez, 1);
        save(preproc_rez_dir, "rez");
    else %  Skip whitening and shifting if already done
        load(preproc_rez_dir, "rez");
    end
    fname = fullfile(output_folder, 'rez.mat');
    if ~isfile(fname) || ~ops_match_flag % Do not re-sort
        temp_rez = rez;
        rez                = preprocessNoWhite(ops);
        rez                = update_struct_new_field(rez, temp_rez);
        rez.ops            = update_struct_new_field(rez.ops, temp_rez.ops);
        %%
        % ORDER OF BATCHES IS NOW RANDOM, controlled by random number generator
        iseed = 1;

        % main tracking and template matching algorithm
        rez = learnAndSolve8b(rez, iseed);

        if ops.remove_duplicate == 1
            % OPTIONAL: remove double-counted spikes - solves issue in which individual spikes are assigned to multiple templates.
            % See issue 29: https://github.com/MouseLand/Kilosort/issues/29
            rez = remove_ks2_duplicate_spikes(rez, 'channel_separation_um', ops.channel_separation_um);
        elseif ops.remove_duplicate == 2 % Updated remove_duplicate, WIP
            rez = remove_ks25_duplicate_spikes(rez, 'channel_separation_um', ops.channel_separation_um);            
        end
        % final merges
        rez = find_merges(rez, 1);
%         rez = find_duplicate_merges(rez);
        % final splits by SVD
        rez = splitAllClusters(rez, 1);

        % decide on cutoff
        rez = set_cutoff(rez);
%         rez = set_cutoff_custom(rez);
        % eliminate widely spread waveforms (likely noise)
        rez.good = get_good_units(rez);

        fprintf('found %d good units \n', sum(rez.good>0))

        % write to Phy
        % final time sorting of spikes, for apps that use st3 directly
        [~, isort]   = sortrows(rez.st3);
        rez.st3      = rez.st3(isort, :);

        % Ensure all GPU arrays are transferred to CPU side before saving to .mat
        rez_fields = fieldnames(rez);
        for i = 1:numel(rez_fields)
            field_name = rez_fields{i};
            if(isa(rez.(field_name), 'gpuArray'))
                rez.(field_name) = gather(rez.(field_name));
            end
        end
        mkdir(output_folder);
        fprintf('Saving results to Phy  \n')
        rezToPhy2(rez, output_folder);
        % if you want to save the results to a Matlab file...
        % discard features in final rez file (too slow to save)
        rez.cProj = [];
        rez.cProjPC = [];
        save(fname, 'rez', '-v7.3');
    else
    end
end
%%
end
function ops_out = update_ops(ops_default, ops_new)
ops_out = ops_default;
field_names = fieldnames(ops_new);
for i = 1:numel(field_names)
    if ~isfield(ops_default, field_names{i})
        warning('Adding a new field: %s', field_names{i});
    end
    ops_out.(field_names{i}) = ops_new.(field_names{i});
end
end
function out_struct = update_struct_new_field(old_struct, new_struct)
out_struct = old_struct;
new_fieldnames = fieldnames(new_struct);
for i = 1:numel(new_fieldnames)
    if ~isfield(old_struct, new_fieldnames{i})
        out_struct.(new_fieldnames{i}) = new_struct.(new_fieldnames{i});
    end
end
end