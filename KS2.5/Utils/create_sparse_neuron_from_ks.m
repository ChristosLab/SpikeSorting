function create_sparse_neuron_from_ks(sessions, ks_working_directory, neuron_output_directory, varargin)
%%CREATE_NEURON_FROM_KS goes through the behavior files in each SESSIONS and
%%create neuron files from matching kilosort output. When there is
%%event information from the ADC channels, add them to trials.
p = inputParser;
p.addParameter('adc_input_directory', [], @isfolder);
%KS option order when spike sorting was repeated
p.addParameter('ks_ops_idx', 0, @isnumeric);
p.addParameter('fr_threshold', 0.1, @isnumeric);
p.parse(varargin{:});
adc_input_directory = p.Results.adc_input_directory;
ks_ops_idx          = p.Results.ks_ops_idx;
fr_threshold        = p.Results.fr_threshold;
%
tic
%%
addpath(genpath('External')) % path to external functions
%%
% cluster_info_directory = fullfile(neuron_output_directory, 'cluster_info');
% if ~isfolder(cluster_info_directory)
%     mkdir(cluster_info_directory);
% end
%%
for i_session = 1:numel(sessions)
    session = sessions(i_session);
    %  Load OE data not used by Kilosort
    oe    = loadOE(session);
    if ~isempty(adc_input_directory)
        %  Load ADC events if available
        adc_event_file_path = fullfile(adc_input_directory, ['*', session.subject_identifier, '*', num2str(session.session_number), '*adc_event*']);
        adc_event_file      = dir(adc_event_file_path);
        if isempty(adc_event_file)
            warning('No adc event file found at %s\n', adc_event_file_path)
        else
            load(fullfile(adc_event_file.folder, adc_event_file.name), 'event_structure');
            analog_events = event_structure.analog_events;
        end
        hp_rms_file_path    = fullfile(adc_input_directory, ['*', session.subject_identifier, '*', num2str(session.session_number), '*hp_RMS*']);
        hp_rms_file         = dir(hp_rms_file_path);
        if isempty(hp_rms_file)
            warning('No hig-pass RMS file found at %s\n', hp_rms_file_path)
        else
            rms_structure = load(fullfile(hp_rms_file.folder, hp_rms_file.name));
        end
    end
    if ~exist('event_structure', 'var') % Creates place holder analog events
        analog_events = struct;
        analog_events.time_sample = zeros([0, 2]);
    end
    %  Load spikes
    ks_out_folder = fullfile(ks_working_directory, session.daq_folder.name, num2str(ks_ops_idx), 'kilosort3');
    % loadKSdir ignores "noise" clusters by default, causing all unlabeled
    % clusters to be treated as "noise" by default.
    sp = loadKSdir(ks_out_folder, setfield(struct, 'excludeNoise', 0));
    sp = load_ks_extra(ks_out_folder, sp);
    if ~isempty(sp.cids)
        sp = zw_merge_clusters(sp, 'fr_treshold', fr_threshold);
    end
    toc
    task_counter = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Add spikes to AllData
    for i_beh = session.beh_order % Loop through chronologically ordered behavior files
        %   Rearrange behavior data
        clear AllData MatData
        %   Load AllData
        load(fullfile(session.beh_files(i_beh).folder, session.beh_files(i_beh).name), 'AllData');
        [task_type, state_code_threshold] = detect_task_type(AllData);
        if state_code_threshold < 0
            %   Non-ephys files (e.g. calibration) dummy coded for exclusion
            continue
        end
        task_counter = task_counter + 1;
        %   Temp AllData structure with spike time added
        AllData_c = add_spikes_sparse(AllData, sp, oe, analog_events, task_counter);
        toc
        %
        AllData_c.trials = rmfield(AllData_c.trials, {'eye_time', 'eye_loc'});
        %   Give timestamp event names according to task type
        AllData_c.trials = verbose_timestamps(AllData_c.trials, task_type);
        %   Outputing
        MatData            = gather_sp(AllData_c, sp);
        MatData.beh_file   = session.beh_files(i_beh).name;
        MatData.daq_folder = session.daq_folder.name;
        MatData.task_type  = task_type;
        MatData.state_code_threshold = state_code_threshold;
        if exist('rms_structure', 'var')
            MatData.madPerChannel = rms_structure.madPerChannel;
            MatData.rmsPerChannel = rms_structure.rmsPerChannel;
        end
        save(fullfile(neuron_output_directory, sprintf('%s_sparse', session.beh_files(i_beh).name(1:end - 4))), 'MatData');
    end
    toc
end
end
%%
function MatData = gather_sp(AllData, sp)
MatData = AllData;
new_fieldnames = fieldnames(sp);
for i = 1:numel(new_fieldnames)
    if and(~isfield(AllData, new_fieldnames{i}), ismember(numel(sp.(new_fieldnames{i})) , [1, size(sp.temps, 1), numel(sp.xcoords), numel(sp.cids)]))
        MatData.(new_fieldnames{i}) = sp.(new_fieldnames{i});
    end
end
end
%%