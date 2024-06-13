%%  Load additional information from Kilosort folder omitted by Spikes
function spikeStructure = load_ks_extra(ksDir, spikeStructure)
spikeStructure.ss                = readNPY(fullfile(ksDir, 'spike_times.npy'));
spikeStructure.similar_templates = readNPY(fullfile(ksDir, 'similar_templates.npy'));
spikeStructure.channel_map       = readNPY(fullfile(ksDir, 'channel_map.npy'));
if exist(fullfile(ksDir, 'cluster_KSLabel.tsv'), 'file') 
        [cids_ks, ks_label]     = readClusterGroupsCSV(fullfile(ksDir, 'cluster_KSLabel.tsv'));
        cids_cgs                = spikeStructure.cids;
        assert(numel(cids_ks) == numel(cids_cgs), 'Cluster id mismatch in %s', ksDir);
        spikeStructure.ks_label = ks_label;
        % Make sure cids ref. original template ids
%         temp_ids                  = [1:size(spikeStructure.temps, 1)] - 1;
%         spikeStructure.ks_label = nan(size(temp_ids));
%         spikeStructure.cgs      = nan(size(temp_ids));
%         spikeStructure.ks_label(ismember_locb(cids_ks, temp_ids)) = ks_label;
%         spikeStructure.cgs(ismember_locb(cids_cgs, temp_ids)) = cgs;
%         spikeStructure.cids     = temp_ids;
else
    error('KS label file not found at %s', fullfile(ksDir, 'cluster_KSLabel.tsv'));
end
end
