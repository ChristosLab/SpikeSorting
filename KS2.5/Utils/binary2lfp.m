function binary2lfp(oebin_file, save_file, varargin)
% Saman Abbaspoor - Feb 2021
% sabbaspoor.neusci@gmail.com
% This function converts continues files to
% downsampled filtered LFP of double precision.
% Analysis Tools from OpenEphys is required for this function to run.
% https://github.com/open-ephys/analysis-tools
% 
% Edited by Zhengyang Wang - Mar 2023

tic
p = inputParser;
addParameter(p,'fs_LFP', 500, @isnumeric)
addParameter(p,'freq_hi', 250, @isnumeric)
addParameter(p, 'n_filt', 3, @isinteger);

parse(p,varargin{:})

fs_LFP  = p.Results.fs_LFP;
freq_hi = p.Results.freq_hi;
n_filt  = p.Results.n_filt;
%%
save_dir = fileparts(save_file);
if ~isfolder(save_dir)
    mkdir(save_dir);
end
%% Load Data
% [D, oebin_json] = loadData(oebin_file);
D = loadData(oebin_file);
bitVolts = matlab_jsondecode_arrayfun_wrapper(@(x) x.bit_volts, D.Header.channels);
fs_raw = D.Header.sample_rate;
downsample_ratio = fs_raw/fs_LFP;
%% Filter Design
[b, a] = butter(n_filt, freq_hi/(fs_raw/2));
%% Fitlering and Downsampling
time_sample = downsample(D.Timestamps, fs_raw/fs_LFP);
% timestamps = timestamps(1:sampling_freq/1000:SampleNum);
n_chan = size(D.Data.Data.mapped, 1);
lfp_size = [n_chan, numel(time_sample)];
lfp = NaN(lfp_size);
for Channel = 1:lfp_size(1)
    toc
    fprintf(1, 'Channel %d started... \n', Channel);
    Data = double(D.Data.Data.mapped(Channel, :)) * bitVolts(Channel); %convert data to double precision
    signal = filtfilt(b, a, Data);
    lfp(Channel, :) = downsample(signal, downsample_ratio);
end
%%
lfp_structure.lfp         = lfp;
lfp_structure.time_sample = time_sample;
lfp_structure.oebin_file  = oebin_file;
lfp_structure.parameters  = p.Results;
%% Save
save(save_file, 'lfp_structure', '-v7.3');
toc
fprintf(1, 'Complete. MAT file saved to %s.\n', save_file);
end




