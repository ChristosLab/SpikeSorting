function [rmsPerChannel, madPerChannel] = zw_computeRawRMS(ksDir, gainFactor)
% Edited from the Spikes function below. -ZW 6/8/2023 function
% [rmsPerChannel, madPerChannel] = computeRawRMS(ksDir, gain[, rawDir])
%
% for spikeglx: gainFactor = 0.6/512/gainSetting*1e6;
%
% ksDir is directory of kilosort results gainFactor will multiply the raw
% data rawDir is location of raw file, if different from ksDir

segment_dur = 10;
n_rand_segments = 10;

pars = loadParamsPy(fullfile(ksDir, 'params.py'));
fs = pars.sample_rate;
nCh = pars.n_channels_dat;

rawFilename = pars.dat_path;

Data = memmapfile(rawFilename,'Format',{pars.dtype, [nCh, fs * segment_dur], 'segments'});
n_segments = numel(Data.Data);
rand_segments = randperm(min(n_segments, n_rand_segments), n_rand_segments);
madPerChannel = zeros(nCh, numel(rand_segments));
rmsPerChannel = zeros(nCh, numel(rand_segments));
for i = 1:numel(rand_segments)
    rawDat = double(Data.Data(rand_segments(i)).segments);
    madPerChannel = mad(rawDat, 1, 2); % Median absolute deviation
    rmsPerChannel = rms(rawDat, 2);
end
% Take the median across segments
madPerChannel = median(madPerChannel, 2);
rmsPerChannel = median(rmsPerChannel, 2);
chanMap = readNPY(fullfile(ksDir, 'channel_map.npy'));
% scale by gain
madPerChannel = madPerChannel(chanMap+1,:).*gainFactor;
rmsPerChannel = rmsPerChannel(chanMap+1,:).*gainFactor;
end