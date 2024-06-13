function create_lfp(sessions, lfp_input_directory, lfp_output_directory, channel_map_dir, varargin)
%%CREATE_LFP goes through the behavior files in each SESSIONS and
%%create neuron files from matching kilosort output
tic
%%
addpath(genpath('External')) % path to external functions
%%
for i_session = 1:numel(sessions)
    session = sessions(i_session);
    %   Load OE data not used by Kilosort
    oe    = loadOE(session);
    %  Load LFP
    LFP_raw_file = dir(fullfile(lfp_input_directory, ['*', session.subject_identifier, '*', num2str(session.session_number), '*raw_LFP*']));
    load(fullfile(LFP_raw_file.folder, LFP_raw_file.name), 'lfp_structure');
    task_counter = 0;
            for i_beh = session.beh_order % Loop through chronologically ordered behavior files
                %   Rearrange behavior data
                clear AllData LFPData
                %   Load AllData
                load(fullfile(session.beh_files(i_beh).folder, session.beh_files(i_beh).name), 'AllData');
                [task_type, state_code_threshold, align_event_order_in_queue] = detect_task_type(AllData);
                if state_code_threshold < 0
                    %   Non-ephys files (e.g. calibration) dummy coded for exclusion
                    continue
                end
                task_counter = task_counter + 1;
                if task_counter ~= session.beh_suffix(i_beh)
                    warning('Behavior file suffix mismatch:\n%s is file %d in sesssion.\n', session.beh_files(i_beh).name, task_counter)
                    task_counter = session.beh_suffix(i_beh);
                end
                %   Find only trials in the current task
                %
                %   Temp AllData structure with spike time added
                AllData_c = add_LFP(AllData, lfp_structure, oe, task_counter);
                %
                AllData_c.trials = rmfield(AllData_c.trials, {'eye_time', 'eye_loc'});
                %   Give timestamp event names according to task type
                AllData_c.trials = verbose_timestamps(AllData_c.trials, task_type);
                LFPData = AllData_c;
                LFPData.beh_file      = session.beh_files(i_beh).name;
                LFPData.daq_session   = session.daq_folder.name;
                LFPData.task_type     = task_type;
                LFPData.channel_map   = load(channel_map_dir);
                save(fullfile(lfp_output_directory, sprintf('%s_LFP', session.beh_files(i_beh).name(1:end - 4))), 'LFPData');
            end
        toc
end
end
%%