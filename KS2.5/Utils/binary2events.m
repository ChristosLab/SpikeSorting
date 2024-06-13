function binary2events(oebin_file, save_file, varargin)
% Zhengyang Wang - May 2023
tic
p = inputParser;
addParameter(p,'abs_threshold', 0.7, @isnumeric)
addParameter(p,'gap_threshold_t', 0.1, @isnumeric)
addParameter(p,'target_channel', 129, @isnumeric)
addParameter(p,'target_processor_idx', 1, @isnumeric)

parse(p,varargin{:})

abs_threshold        = p.Results.abs_threshold;
gap_threshold_t      = p.Results.gap_threshold_t;
target_channel       = p.Results.target_channel;
target_processor_idx = p.Results.target_processor_idx;
%%
save_dir = fileparts(save_file);
if ~isfolder(save_dir)
    mkdir(save_dir);
end
%% Load Data
D = loadData(oebin_file, 'processor_idx', target_processor_idx);
bitVolts = matlab_jsondecode_arrayfun_wrapper(@(x) x.bit_volts, D.Header.channels);
fs_raw = D.Header.sample_rate;
%%
analog_events = struct;
for i_ch = 1:numel(target_channel)
    toc
    fprintf(1, 'Channel %d started... \n', target_channel(i_ch));
    [onset_sample, offset_sample] = detect_analog_edge(D.Data.Data.mapped(target_channel(i_ch), :) * bitVolts(target_channel(i_ch)), fs_raw, abs_threshold, gap_threshold_t);
    if numel(onset_sample) > numel(offset_sample)
        warning('More adc on event than off event on Channel %d in %s\n', target_channel(i_ch), session.daq_folder.name);
        offset_sample = [offset_sample; offset_sample(end) + 1];
    elseif numel(onset_sample) < numel(offset_sample)
        warning('More adc off event than on event on Channel %d in %s\n', target_channel(i_ch), session.daq_folder.name);
        onset_sample = [1; onset_sample];
    end
    analog_events(i_ch).time_sample = [D.Timestamps(onset_sample), D.Timestamps(offset_sample)];
    analog_events(i_ch).channel = D.Header.channels(target_channel(i_ch));
end
%% Fitlering and Downsampling
%%
event_structure.analog_events = analog_events;
event_structure.oebin_file  = oebin_file;
event_structure.parameters  = p.Results;
%% Save
save(save_file, 'event_structure', '-v7.3');
toc
fprintf(1, 'Complete. MAT file saved to %s.\n', save_file);
end



