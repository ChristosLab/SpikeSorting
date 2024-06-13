function log_ks(sessions, log_file, end_flag)
fid = fopen(log_file, 'a+');
name_sessions_to_sort = arrayfun(@(x) x.daq_folder.name, sessions, 'UniformOutput', false);
dts = datestr(datetime);
switch end_flag
    case 0
    fprintf(1, '@ %s Starting sorting the following sessions:\n', dts);
    fprintf(fid, '@ %s Starting sorting the following sessions:\n', dts);
    for i = 1:numel(sessions)
        fprintf(1, '%s\n', name_sessions_to_sort{i});
        fprintf(fid, '%s\n', name_sessions_to_sort{i});
    end
    case 1
    fprintf(1, '@ %s Finished sorting\n%s\n.', dts, sessions(1).daq_folder.name);
    fprintf(fid, '@ %s Finished sorting\n%s\n.', dts, sessions(1).daq_folder.name);
    case 2
    fprintf(1, '@ %s Starting generating raw LFP:\n', dts);
    fprintf(fid, '@ %s Starting generating raw LFP:\n', dts);
    case 3
    fprintf(1, '@ %s Finished generating LFP\n%s.\n', dts, sessions(1).daq_folder.name);
    fprintf(fid, '@ %s Finished generating LFP\n%s.\n', dts, sessions(1).daq_folder.name);
    case 4
        fprintf(1, '@ %s Finished generating raw LFP.\n', dts);
        fprintf(fid, '@ %s Finished generating raw LFP.\n', dts);
    case 5
        fprintf(1, '@ %s Starting computing hp rms:\n', dts);
        fprintf(fid, '@ %s Starting computing hp rms:\n', dts);
    case 6
        fprintf(1, '@ %s Finished computing hp rms:\n', dts);
        fprintf(fid, '@ %s Finished computing hp rms:\n', dts);
end
fclose(fid);
end