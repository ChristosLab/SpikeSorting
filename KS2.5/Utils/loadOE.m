function oe_structure = loadOE(session)
%loadOE
%%
% Decoding channels in the Digital Inputs of the acquisition board
% connected via an OE I/O board
% (https://open-ephys.github.io/acq-board-docs/User-Manual/Peripheral-devices.html#peripheraldevices)
adc_helper_channel_state   = 4;   %  DC channel reporting adc events (e.g. laser)
session_time_channel_state = 3;   %  DC channel for session on
trial_time_channel_state   = 2;   %  DC channel for trial on
photodiode_channel_state   = 1;   %  DC channel for cue on
%%
%  Load OE info files
oe_structure.oe_info = jsondecode(fileread(fullfile(session.daq_files.oebin_file.folder, session.daq_files.oebin_file.name)));
fs = oe_structure.oe_info.events{session.daq_event_idx}.sample_rate;
%
%  OE array of event channel rising (+n) and falling (-n) crosses
channel_state_  = readNPY(fullfile(session.daq_files.channel_states_file.folder, session.daq_files.channel_states_file.name));
%
%  OE array of event state sample number in time
%   corresponds to channel_state_ (e.g. [100001, 115000] for a 0.5-sceond
%   pulse @ 30K hz)
channel_sample_ = readNPY(fullfile(session.daq_files.channel_timestamps_file.folder, session.daq_files.channel_timestamps_file.name));
%
%  OE array of timestamps for the continuous signal
%   Synchronizes the sample numbers in the continuous data to the clock
%   used across other streams of data (e.g. DC event channels)
oe_data = load_open_ephys_binary_timestamp_rescue(fullfile(session.daq_files.oebin_file.folder, session.daq_files.oebin_file.name), 'continuous', session.daq_continuous_idx, 'mmap');
oe_structure.continuous_timestamp = oe_data.Timestamps;
%
%  Decode DC events
if sum(channel_state_ == -session_time_channel_state) < sum(channel_state_ == session_time_channel_state)
    warning('More session on event than off event in %s\n', session.daq_folder.name);
    channel_sample_ = [channel_sample_; channel_sample_(end) + 1];
    channel_state_  = [channel_state_; -session_time_channel_state];
elseif sum(channel_state_ == -session_time_channel_state) > sum(channel_state_ == session_time_channel_state)
    warning('More session off event than on event in %s\n', session.daq_folder.name);
    channel_sample_ = [1; channel_sample_];
    channel_state_  = [session_time_channel_state; channel_state_];
end
oe_structure.session_time_event    = [channel_sample_(channel_state_ == session_time_channel_state), channel_sample_(channel_state_ == -session_time_channel_state)];
oe_structure.trial_time_event      = [channel_sample_(channel_state_ == trial_time_channel_state), channel_sample_(channel_state_ == -trial_time_channel_state)];
oe_structure.photodiode_time_event = [channel_sample_(channel_state_ == photodiode_channel_state), channel_sample_(channel_state_ == -photodiode_channel_state)];
oe_structure.adc_helper_time_event = [channel_sample_(channel_state_ == adc_helper_channel_state), channel_sample_(channel_state_ == -adc_helper_channel_state)];
oe_structure.photodiode_time_event = fix_photodiode_gap(oe_structure.photodiode_time_event, fs);
end
%%
function photodiode_time_event_out = fix_photodiode_gap(photodiode_time_event, fs)
%   The FHC synchronizer outputs a single pulse of a fixed width when the
%   pixels light up across a certain threshold at the beginning of each
%   frame (@ ~60 Hz, specific to monitor specs). When the timing of
%   luminance crossing jitters on each frame, successive pulses could have
%   no overlap resulting in gaps in "photodiode_event_time".
%   FIX_PHOTODIODE_GAP removes gaps samller than the duration of a frame.
gap_threshold = 1 / 60 *fs;
if isempty(photodiode_time_event)
    photodiode_time_event_out = photodiode_time_event;
    return
end
photodiode_time_event_gap = photodiode_time_event(2:end, 1) - photodiode_time_event(1:end - 1, 2);
gap_to_delete             = find(photodiode_time_event_gap < gap_threshold);
photodiode_time_event_on_new  = photodiode_time_event(:, 1);
photodiode_time_event_off_new = photodiode_time_event(:, 2);
photodiode_time_event_on_new(gap_to_delete + 1) = [];
photodiode_time_event_off_new(gap_to_delete)    = [];
photodiode_time_event_out                       = [photodiode_time_event_on_new, photodiode_time_event_off_new];
if ~isempty(gap_to_delete)
warning('%d out of %d gaps deleted from photodiode events\n', numel(gap_to_delete), size(photodiode_time_event, 1))
end
end