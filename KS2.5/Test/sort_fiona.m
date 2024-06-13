clc
clear
fclose all;
%%
zw_setpath;
log_file = 'ks_log.txt';
%%  Find behavior and OE files
% subject_identifier = {'PIC', 'ROS', 'UNI', 'OLI', 'TRI', 'VIK'};
subject_identifier = {'FIO'};
session_range = [];
beh_dir = 'F:\Temp\beh'; % Folder for behavior files
daq_dir = 'F:\Temp'; % Folder for raw ephys data files
ks_dir  = 'F:\Temp'; % Folder for storing sorted data
raw_lfp_dir = 'F:\Temp'; % Folder for storing filtered and downsampled LFP data
sessions = find_oe_beh_files(beh_dir, daq_dir, subject_identifier, session_range);
% check_sorted_session(sessions);
%%  list of ops parameters to test
%   Do not change parameters used for whitening, since whitened data is
%   shared across runs.
start_ops = 1;
remove_duplicate = 1;
ops_list = {};
ops_ = struct;
%   Default
ops_ = struct;
ops_.nblocks = 0; 
ops_list{1} = ops_;
%%  Sorting and creating LFP
% log_ks(sessions, log_file, 0);
for i = 1:numel(sessions)
    oe = loadOE(sessions(i));
    chanMapFile = find_chanMapFile_temp(oe);
    ks_working_directory = fullfile(ks_dir, sessions(i).subject_identifier);
    rootO = fullfile(ks_working_directory, sessions(i).daq_folder.name);
    sessions(i).ks_folder = test_ks_params(sessions(i).daq_files.continuous_file.folder, rootO, chanMapFile, ops_list, 'start_ops', start_ops, 'remove_duplicate', remove_duplicate);
    close all
    log_ks(sessions(i), log_file, 1);
end
fclose all
log_ks(sessions, log_file, 2);
% for i = 1:numel(sessions)
%     create_lfp_raw(sessions(i), raw_lfp_dir);
%     log_ks(sessions(i), log_file, 3);
% end
log_ks(sessions, log_file, 4);
%%  Compute RMS from high-pass filtered data
% log_ks(sessions, log_file, 5);
% create_ks_rms(sessions, raw_lfp_dir);
% log_ks(sessions, log_file, 6);
%%  Find ADC events
% for i = 1:numel(sessions)
%     oe = loadOE(sessions(i));
%     chanMapFile = find_chanMapFile(oe);
%     if ~isempty(regexp(chanMapFile, 'adc', 'once'))
%         create_adc_raw(sessions(i), raw_lfp_dir)
%     end
% end

function chanMapFile = find_chanMapFile_temp(oe)
n_chan = oe.oe_info.continuous.num_channels;
switch n_chan
    case 1
        chanMapFile = 'tungsten_1.mat';
    case 16
        chanMapFile = 'Linear_16_ch_150_pitch_plexon_V.mat';
    case 32
        chanMapFile = 'Linear_32_ch_75_pitch_plexon_S.mat';
    case 40
        chanMapFile = 'Linear_32ch+8adc.mat';
    case 128
        chanMapFile = 'DA128-2_chanMap.mat';
    case num2cell(128 + [1:8])
        chanMapFile = sprintf('DA128-2_chanMap_%dadc.mat', n_chan - 128);
    case 256
        chanMapFile = 'DA128-2X2_chanMap.mat';
    case mat2cell(256 + [1:8])
        chanMapFile = sprintf('DA128-2X2_chanMap_%dadc.mat', n_chan - 256);
end
end