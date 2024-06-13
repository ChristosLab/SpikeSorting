clc
clear
fclose all;
zw_setpath;
%%  Convert Kilosort output to matlab records
ks_dir  = 'Z:\Development_project_2019\VanderbiltDAQ\KS_out'; % Folder for storing sorted data
ks_output_dirs = dir(fullfile(ks_dir, '*\*\1\kilosort3*'));
sp_dir  = 'F:\Database\VanderbiltDAQ\spike_structure'; % Folder for storing filtered and downsampled LFP data
probe_table = readtable('C:\Users\cclab\Downloads\Protocol_book_upload.xlsx', 'Sheet', 'probe');
session_table = readtable('C:\Users\cclab\Downloads\Protocol_book_upload.xlsx', 'Sheet', 'session');
%%
subject_identifier = {'UNI'};
subject_pattern = strjoin(subject_identifier, '|');
session_pattern = '\d{3}';
exp_pattern     = sprintf('(%s)%s', subject_pattern, session_pattern);
%%
tic
for i = 1:numel(ks_output_dirs)
    toc
    current_session_name = regexp(ks_output_dirs(i).folder, exp_pattern, 'match');
    if isempty(current_session_name)
        continue
    end
    current_output_name = [current_session_name{1}, '_sp.mat']
    current_output_fullpath = fullfile(sp_dir, current_output_name);
    if isfile(current_output_fullpath)
        continue
    end
    current_dir = fullfile(ks_output_dirs(i).folder, ks_output_dirs(i).name);
    sp = loadKSdir(current_dir, setfield(struct, 'excludeNoise', 0));
    sp = load_ks_extra(current_dir, sp);
    sp.session_name = current_session_name;
    if ~isempty(sp.cids)
        sp = zw_merge_clusters(sp);
        sp = assign_session_probe_info(sp, session_table, probe_table);
    end
    save(current_output_fullpath, "sp");
end