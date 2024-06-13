function create_sparse_neuron_from_sp(sessions, sp_directory, neuron_output_directory, varargin)
%%CREATE_NEURON_FROM_SP goes through the behavior files in each SESSIONS
%%and create neuron files using spike_structure created from matching
%%kilosort outputs. When there is event information from the ADC channels,
%%add them to trials.
p = inputParser;
p.addParameter('adc_input_directory', [], @isfolder);
p.addParameter('split_by_area', []);
p.addParameter('stationary', 1);
p.parse(varargin{:});
adc_input_directory = p.Results.adc_input_directory;
split_by_area       = p.Results.split_by_area;
stationary           = p.Results.stationary;
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
    session     = sessions(i_session);
    %  Load OE data not used by Kilosort
    oe          = loadOE(session);
    %  Load spikes
    sp_filename = sprintf('%s%03.f_sp.mat', session.subject_identifier, session.session_number);
    sp_dir      = fullfile(sp_directory, sp_filename);
    if ~isfile(sp_dir)
        continue
    end
    load(sp_dir, 'sp');
    if ~isempty(adc_input_directory)
        %  Load ADC events if available (those sampled on the same clock as the continuous data)
        adc_event_file_path = fullfile(adc_input_directory, ['*', session.subject_identifier, '*', num2str(session.session_number), '_adc_event*']);
        adc_event_file      = dir(adc_event_file_path);
        if isempty(adc_event_file)
            warning('No adc event file found at %s\n', adc_event_file_path)
            % Creates place holder analog events
            analog_events = struct;
            analog_events.time_sample = zeros([0, 2]);
        else
            adc_loader    = load(fullfile(adc_event_file.folder, adc_event_file.name), 'event_structure');
            analog_events = adc_loader.event_structure.analog_events;
        end
        %  Load AUX ADC events if available (those sampled on a different clock from the continuous data)
        aux_event_file_path = fullfile(adc_input_directory, ['*', session.subject_identifier, '*', num2str(session.session_number), '_aux_adc_event*']);
        aux_event_file      = dir(aux_event_file_path);
        if isempty(aux_event_file)
            warning('No aux adc event file found at %s\n', aux_event_file_path)
            %   Creates place holder aux events
            aux_events = struct;
            aux_events.time_sample = zeros([0, 2]);

        else
            aux_loader = load(fullfile(aux_event_file.folder, aux_event_file.name), 'event_structure');
            aux_events = aux_loader.event_structure.analog_events;
        end
        hp_rms_file_path    = fullfile(adc_input_directory, ['*', session.subject_identifier, '*', num2str(session.session_number), '*hp_RMS*']);
        hp_rms_file         = dir(hp_rms_file_path);
        if isempty(hp_rms_file)
            warning('No hig-pass RMS file found at %s\n', hp_rms_file_path)
            rms_structure = [];
            sp.amp_rms = [];
            sp.amp_mad = [];
        else
            rms_structure = load(fullfile(hp_rms_file.folder, hp_rms_file.name));
            for i_clu = 1:numel(sp.cluster_tempAmps)
                sp.amp_rms(i_clu) = sp.cluster_tempAmps(i_clu)/rms_structure.rmsPerChannel(sp.cluster_chan(i_clu));
                sp.amp_mad(i_clu) = sp.cluster_tempAmps(i_clu)/rms_structure.madPerChannel(sp.cluster_chan(i_clu));
            end
        end
    end
    if ~isempty(aux_events(1).time_sample) % When multiple processors each record streams of ADC
        oe = align_analog_events(oe, analog_events, aux_events);
    end
    if split_by_area
        [area_labels, sp] = parse_sp_by_area(sp);
    else
        area_labels = {''};
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
        for sp_idx = 1:numel(sp)
            fname = fullfile(neuron_output_directory, sprintf('%s%s_sparse', session.beh_files(i_beh).name(1:end - 4), area_labels{sp_idx}));
            if isfile(fname)
                continue
            end
            sp_single = sp(sp_idx);
            AllData_c = add_spikes_sparse(AllData, sp_single, oe, analog_events, task_counter);
            toc
            %
            AllData_c.trials = rmfield(AllData_c.trials, {'eye_time', 'eye_loc'});
            %   Give timestamp event names according to task type
            AllData_c.trials = verbose_timestamps(AllData_c.trials, task_type);
            %   Outputing
            MatData            = gather_sp(AllData_c, sp_single);
            MatData.beh_file   = session.beh_files(i_beh).name;
            MatData.daq_folder = session.daq_folder.name;
            MatData.task_type  = task_type;
            MatData.state_code_threshold = state_code_threshold;
            if stationary
                MatData = stationarityCheck_wrapper(MatData, 'statecode_threshold', MatData.state_code_threshold - 2);
            end
            MatData = classify_single_unit(MatData);
            save(fname, 'MatData');
        end
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
    if strcmp('cluster_waveforms', new_fieldnames{i})
        MatData.(new_fieldnames{i}) = sp.(new_fieldnames{i});
    end
end
end
%%