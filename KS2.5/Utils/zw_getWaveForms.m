function wf = zw_getWaveForms(gwfparams)
% Edited from getWaveForms in the *spikes* package (https://github.com/cortex-lab/spikes).
% Zhenygang wang May 2023
%%%%
% function wf = getWaveForms(gwfparams)
%
% Extracts individual spike waveforms from the raw datafile, for multiple
% clusters. Returns the waveforms and their means within clusters.
%
% Contributed by C. Schoonover and A. Fink
%
% % EXAMPLE INPUT
% gwfparams.fileName = '/path/to/data/data.dat';         % .dat file containing the raw 
% gwfparams.chMapfile = '/path/to/data/channel_map.npy';  
% gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
% gwfparams.wfWin = [-40 41];              % Number of samples before and after spiketime to include in waveform
% gwfparams.nWf = 2000;                    % Number of waveforms per unit to pull out
% gwfparams.spikeTimes =    [2,3,5,7,8,9]; % Vector of cluster spike times (in samples) same length as .spikeClusters
% gwfparams.spikeClusters = [1,2,1,1,1,2]; % Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes
%
% % OUTPUT
% wf.unitIDs                               % [nClu,1]            List of cluster IDs; defines order used in all wf.* variables
% wf.spikeTimeKeeps                        % [nClu,nWf]          Which spike times were used for the waveforms
% wf.waveForms                             % [nClu,nWf,nCh,nSWf] Individual waveforms
% wf.waveFormsMean                         % [nClu,nCh,nSWf]     Average of all waveforms (per channel)
%                                          % nClu: number of different clusters in .spikeClusters
%                                          % nSWf: number of samples per waveform
%
% % USAGE
% wf = getWaveForms(gwfparams);

% Load .dat and KiloSort/Phy output
chMap = readNPY(gwfparams.chMapfile)+1;               % Order in which data was streamed to disk; must be 1-indexed for Matlab
nChInMap = numel(chMap);
nCh      = nChInMap;

fileName = gwfparams.fileName;           
filenamestruct = dir(fileName);
dataTypeNBytes = numel(typecast(cast(0, gwfparams.dataType), 'uint8')); % determine number of bytes per sample
nSamp = filenamestruct.bytes/(nCh*dataTypeNBytes);  % Number of samples per channel
wfNSamples = length(gwfparams.wfWin(1):gwfparams.wfWin(end));
mmf = memmapfile(fileName, 'Format', {gwfparams.dataType, [nCh nSamp], 'x'});

% Read spike time-centered waveforms
unitIDs = unique(gwfparams.spikeClusters);
numUnits = numel(unitIDs);
waveFormsMean = nan(numUnits,nChInMap,wfNSamples);

for curUnitInd=1:numUnits
    curUnitID = unitIDs(curUnitInd);
    curSpikeTimes = gwfparams.spikeTimes(gwfparams.spikeClusters==curUnitID);
    curUnitnSpikes = numel(curSpikeTimes);
    spikeTimesRP = curSpikeTimes(randperm(curUnitnSpikes));
    curNSpikes = min([gwfparams.nWf curUnitnSpikes]);
    spikeTimeKeeps = sort(spikeTimesRP(1:curNSpikes));
    waveForms = int16(zeros(curNSpikes,nChInMap,wfNSamples));

    for curSpikeTime = 1:curNSpikes
        tmpWf = mmf.Data.x(1:nCh,spikeTimeKeeps(curSpikeTime)+gwfparams.wfWin(1):spikeTimeKeeps(curSpikeTime)+gwfparams.wfWin(end));
        waveForms(curSpikeTime,:,:) = tmpWf(chMap,:);
    end
    waveFormsMean = squeeze(nanmean(double(waveForms),1));
%     disp(['Completed ' int2str(curUnitInd) ' units of ' int2str(numUnits) '.']);
wf(curUnitInd).unitID = curUnitID;
wf(curUnitInd).spikeTimeKeeps = spikeTimeKeeps;
wf(curUnitInd).waveForms = waveForms;
wf(curUnitInd).waveFormsMean = waveFormsMean;
end


% Package in wf struct

end
