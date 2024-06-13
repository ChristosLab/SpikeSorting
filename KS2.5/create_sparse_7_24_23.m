subject_identifier = {'PIC', 'ROS', 'UNI', 'OLI'};
session_range = [];
beh_dir = 'F:\Database\VanderbiltDAQ\beh'; % Folder for behavior files
daq_dir = 'Z:\Development_project_2019\VanderbiltDAQ\Open Ephys'; % Folder for raw ephys data files
raw_lfp_dir = 'Z:\Development_project_2019\VanderbiltDAQ\raw_LFP'; % Folder for storing filtered and downsampled LFP data
sp_dir  = 'F:\Database\VanderbiltDAQ\spike_structure';
neuron_output_directory = 'F:\Database\VanderbiltDAQ\NeuronFiles';
single_neuron_output_directory = 'Z:\Development_project_2019\VanderbiltDAQ\single_neuron_files';
% sessions = find_oe_beh_files(beh_dir, daq_dir, subject_identifier, session_range);
%%
% create_sparse_neuron_from_sp(sessions(98+8:end), sp_dir, neuron_output_directory, 'adc_input_directory', raw_lfp_dir);
%%
% neuron_table = database_table([], :);
% neuron_starts = (3 - 1 + (1:numel(subject_identifier))) .* 10000;
%%
for i_subject = 1:numel(subject_identifier)
    sparse_neurons = dir(fullfile(neuron_output_directory, ['*', subject_identifier{i_subject}, '*.mat']));
    session_number = arrayfun(@(x) str2num(x.name(4:6)), sparse_neurons);
    [~, session_order] = sort(session_number);
    sparse_neurons = sparse_neurons(session_order);
    session_number = session_number(session_order);
    for i_sparse = 1:numel(sparse_neurons)
        current_neuron_count = double(find_neuron_count(neuron_table, subject_identifier{i_subject}, session_number(i_sparse)));
        prev_neuron_count = double(find_neuron_count(neuron_table, subject_identifier{i_subject}, session_number(i_sparse) - 1));
        if current_neuron_count > prev_neuron_count
            continue
        end
        if isempty(prev_neuron_count)
            prev_neuron_count = neuron_starts(i_subject);
        end
        load(fullfile(sparse_neurons(i_sparse).folder, sparse_neurons(i_sparse).name), 'MatData');
        neuron_table = sparse_to_single_mat(MatData, prev_neuron_count, neuron_table, fullfile(single_neuron_output_directory, subject_identifier{i_subject}));
        writetable(neuron_table, 'neuron_table', 'WriteRowNames',true, 'FileType','spreadsheet');
    end
end