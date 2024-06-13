fr_threshold = 0.1;
session = sessions(5);
sp = loadKSdir(fullfile(ks_working_directory, session.daq_folder.name, '1/kilosort3'));
sp = load_ks_extra(fullfile(ks_working_directory, session.daq_folder.name, '1/kilosort3'), sp);
sp = zw_merge_clusters(sp, fr_threshold);
%%
gwfparams.fileName = fullfile(ks_working_directory, session.daq_folder.name, 'temp_wh.dat');         % .dat file containing the raw 
gwfparams.chMapfile = fullfile(ks_working_directory, session.daq_folder.name, '/1/kilosort3/channel_map.npy');
gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
gwfparams.wfWin = [-25 40];              % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 500;                    % Number of waveforms per unit to pull out
gwfparams.spikeTimes =    sp.ss; % Vector of cluster spike times (in samples) same length as .spikeClusters
gwfparams.spikeClusters = sp.clu; % Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes
% gwfparams.spikeTimes =    gwfparams.spikeTimes(gwfparams.spikeClusters); 
% gwfparams.spikeClusters = gwfparams.spikeClusters(gwfparams.spikeClusters); 
wf = zw_getWaveForms(gwfparams);
%%
f = figure;
% for i = [14, 16, 19, 74, 79, 84, 88, 89, 90, 94, 97, 98, 102, 105,
% 106,107, 141, 153, 166, 192, 196, 22, 39, 40, 86, 103, 108, 149] % 104
% for i = [2, 3, 13, 19, 71 77, 26, 49, 54, 63, 83, 84, 137, 204, 205, 230, 231, 317, 320,128, 131, 161, 165] % 103
for i = [30, 86, 99, 110 , 117]
hold on
% title(i)
zw_plotWaveform(squeeze(wf(i).waveForms), sp.xcoords, sp.ycoords, 'n_chan', 10)
pdf_filename = fullfile('C:\Projects\SpikeSorting\KS2.5\Figures', sprintf('%s_%d.pdf', session.daq_folder.name(1:6), i));
exportgraphics(f, pdf_filename,"Append",true, 'ContentType', 'image', 'Resolution', 300)
% pause
clf
end
%%
%%
