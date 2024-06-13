function create_adc_raw(sessions, raw_adc_dir)
for i_session = 1:numel(sessions)
    session_name             = sessions(i_session).daq_folder.name(1:6);
    continous_adc_channel = sessions(i_session).continous_adc_channel;
    if ~isempty(continous_adc_channel)
        continuous_adc_save_file = fullfile(raw_adc_dir, [session_name, '_adc_event.mat']);
        continuous_processor_idx = sessions(i_session).daq_continuous_idx;
        continuous_processor     = sessions(i_session).oe_info.continuous(continuous_processor_idx).source_processor_name;
        if isfile(continuous_adc_save_file)
            fprintf(1, '%s already exists.\n', continuous_adc_save_file)
        else
            fprintf(1, 'Start binary2events on %s processor %s.\n', session_name, continuous_processor);
            binary2events(...
                fullfile(sessions(i_session).daq_files.oebin_file.folder, sessions(i_session).daq_files.oebin_file.name), ...
                continuous_adc_save_file, 'target_channel', continous_adc_channel, 'target_processor_idx', continuous_processor_idx...
                );
        end
    end
    aux_adc_channel = sessions(i_session).aux_adc_channel;
    if ~isempty(aux_adc_channel)
        aux_adc_save_file = fullfile(raw_adc_dir, [session_name, '_aux_adc_event.mat']);
        aux_processor_idx = sessions(i_session).daq_aux_idx;
        aux_processor     = sessions(i_session).oe_info.continuous(aux_processor_idx).source_processor_name;
        if isfile(aux_adc_save_file)
            fprintf(1, '%s already exists.\n', aux_adc_save_file)
        else
            fprintf(1, 'Start binary2events on %s processor %s.\n', session_name, aux_processor);
            binary2events(...
                fullfile(sessions(i_session).daq_files.oebin_file.folder, sessions(i_session).daq_files.oebin_file.name), ...
                aux_adc_save_file, 'target_channel', aux_adc_channel, 'target_processor_idx', aux_processor_idx...
                );
        end
    end
end
end