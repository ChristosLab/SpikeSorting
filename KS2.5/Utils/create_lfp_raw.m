function create_lfp_raw(sessions, raw_lfp_dir)
for i_session = 1:numel(sessions)
    session_name = sessions(i_session).daq_folder.name(1:6);
    save_file    = fullfile(raw_lfp_dir, [session_name, '_raw_LFP.mat']);
    if isfile(save_file)
        fprintf(1, '%s already exists.\n', save_file)
    else
        fprintf(1, 'Start binary2lfp on %s.\n', session_name);
        binary2lfp(fullfile(sessions(i_session).daq_files.oebin_file.folder, sessions(i_session).daq_files.oebin_file.name), save_file);
    end
end