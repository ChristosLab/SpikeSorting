clear
zw_setpath
subject_identifier = {'PIC', 'ROS', 'UNI', 'OLI'};
session_range = [];
beh_dir = 'F:\Database\VanderbiltDAQ\beh'; % Folder for behavior files
daq_dir = 'Z:\Development_project_2019\VanderbiltDAQ\Open Ephys'; % Folder for raw ephys data files
raw_lfp_dir = 'Z:\Development_project_2019\VanderbiltDAQ\raw_LFP'; % Folder for storing filtered and downsampled LFP data
sp_dir  = 'F:\Database\VanderbiltDAQ\spike_structure';
neuron_output_directory = 'F:\Database\VanderbiltDAQ\NeuronFiles';
single_neuron_output_directory = 'Z:\Development_project_2019\VanderbiltDAQ\single_neuron_files';
sessions = find_oe_beh_files(beh_dir, daq_dir, subject_identifier, session_range);
%%
sessions([49, 92]) = [];
%%
create_sparse_neuron_from_sp(sessions, sp_dir, neuron_output_directory, 'adc_input_directory', raw_lfp_dir, 'split_by_area', 1, 'stationary', 1);