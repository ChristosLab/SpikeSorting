function [psdPerChannel, f] = zw_computeRawPSD(ksDir, varargin)
% Edited from the Spikes function below. -ZW 6/8/2023 function
% [rmsPerChannel, madPerChannel] = computeRawRMS(ksDir, gain[, rawDir])
%
% for spikeglx: gainFactor = 0.6/512/gainSetting*1e6;
%
% ksDir is directory of kilosort results gainFactor will multiply the raw
% data rawDir is location of raw file, if different from ksDir

p = inputParser;
p.addParameter('f', [], @isnumeric);
p.parse(varargin{:});

f = p.Results.f;

pars = loadParamsPy(fullfile(ksDir, 'params.py'));

n_window = 500;
f_res    = 10;
segment_dur = 20;
n_rand_segments = 10;
fs = pars.sample_rate;
n_fft = fs/f_res;
nCh = pars.n_channels_dat;
n_sample_per_segment = fs * segment_dur;
if isempty(f)
    [~, f] = pwelch(zeros([n_sample_per_segment, 1]), [], [], n_fft, fs, 'onesided');
end
rawFilename = pars.dat_path;
Data = memmapfile(rawFilename,'Format',{pars.dtype, [nCh, n_sample_per_segment], 'segments'});
n_segments = numel(Data.Data);
rand_segments = randperm(min(n_segments, n_rand_segments), n_rand_segments);
psdPerChannel = zeros(nCh, numel(f), numel(rand_segments));
for i = 1:numel(rand_segments)
    rawDat = double(Data.Data(rand_segments(i)).segments);
    psdPerChannel(:, :, i) = pwelch(rawDat',[], [], f, fs)';
    i
end
psdPerChannel = squeeze(mean(psdPerChannel, 3));
end