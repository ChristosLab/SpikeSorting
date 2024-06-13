clear
zw_setpath
database2019_fname = 'Z:\Development_project_2019\VanderbiltDAQ\Database2019_copy\Dev_Project2019.accdb';
if isfile(database2019_fname)
    access_mdb = AccessDatabase_OLEDB(database2019_fname);
    database_table = get_access_mdb_table(access_mdb,[],{'Neuron'});
end
subject_identifier = {'PIC', 'ROS', 'UNI', 'OLI'};
session_range = [];
beh_dir = 'F:\Database\VanderbiltDAQ\beh'; % Folder for behavior files
daq_dir = 'Z:\Development_project_2019\VanderbiltDAQ\Open Ephys'; % Folder for raw ephys data files
raw_lfp_dir = 'Z:\Development_project_2019\VanderbiltDAQ\raw_LFP'; % Folder for storing filtered and downsampled LFP data
sp_dir  = 'F:\Database\VanderbiltDAQ\spike_structure';
single_neuron_output_directory = 'F:\Database\VanderbiltDAQ\NeuronFiles';
single_single_neuron_output_directory = 'F:\Database\VanderbiltDAQ\single_neuron_files';
single_mua_output_directory = 'F:\Database\VanderbiltDAQ\mua_files';
neuron_table = database_table([], :);
mua_table    = database_table([], :);
neuron_starts = (3 - 1 + (1:numel(subject_identifier))) .* 10000;
mua_starts    = (3 - 1 + (1:numel(subject_identifier))) .* 10000;
%%
for i_subject = 1:numel(subject_identifier)
    sparse_neurons = dir(fullfile(single_neuron_output_directory, ['*', subject_identifier{i_subject}, '*.mat']));
    session_number = arrayfun(@(x) str2num(x.name(4:6)), sparse_neurons);
    [~, session_order] = sort(session_number);
    sparse_neurons = sparse_neurons(session_order);
    session_number = session_number(session_order);
    single_neuron_output_dir = fullfile(single_single_neuron_output_directory, subject_identifier{i_subject});
    mua_output_dir    = fullfile(single_mua_output_directory, subject_identifier{i_subject});
    if ~isfolder(single_neuron_output_dir)
        mkdir(single_neuron_output_dir)
    end
    if ~isfolder(mua_output_dir)
        mkdir(mua_output_dir)
    end

    for i_sparse = 1:numel(sparse_neurons)
        current_neuron_count = double(find_neuron_count(neuron_table, subject_identifier{i_subject}, session_number(i_sparse)));
        prev_neuron_count = double(find_neuron_count(neuron_table, subject_identifier{i_subject}, session_number(i_sparse) - 1));
        current_mua_count = double(find_neuron_count(mua_table, subject_identifier{i_subject}, session_number(i_sparse)));
        prev_mua_count = double(find_neuron_count(mua_table, subject_identifier{i_subject}, session_number(i_sparse) - 1));
        if current_neuron_count > prev_neuron_count
            continue
        end
        if isempty(prev_neuron_count)
            prev_neuron_count = neuron_starts(i_subject);
        end
        if isempty(prev_mua_count)
            prev_mua_count = mua_starts(i_subject);
        end
        load(fullfile(sparse_neurons(i_sparse).folder, sparse_neurons(i_sparse).name), 'MatData');
        [neuron_table, mua_table] = sparse_to_single_mat(MatData, prev_neuron_count, neuron_table, prev_mua_count, mua_table, single_neuron_output_dir, mua_output_dir);
        writetable(neuron_table, 'neuron_table', 'WriteRowNames',true, 'FileType','spreadsheet');
        writetable(mua_table, 'mua_table', 'WriteRowNames',true, 'FileType','spreadsheet');
    end
end