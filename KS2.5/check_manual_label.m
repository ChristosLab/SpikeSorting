all_ksdir = dir('Z:\Development_project_2019\VanderbiltDAQ\KS_out\*\*_*');
good_ksdir = nan(size(all_ksdir));
for i = 1:numel(all_ksdir)
    fprintf('%d out of %d\n', i, numel(all_ksdir));
    good_ksdir(i) = check_ks_label(fullfile(all_ksdir(i).folder, fullfile(all_ksdir(i).name, '1\kilosort3')));
end
function good = check_ks_label(ksDir)
spikeStructure                   = loadKSdir(ksDir);
spikeStructure.ss                = readNPY(fullfile(ksDir, 'spike_times.npy'));
spikeStructure.similar_templates = readNPY(fullfile(ksDir, 'similar_templates.npy'));
if exist(fullfile(ksDir, 'cluster_KSLabel.tsv'), 'file') 
        [cids_ks, ks_label]     = readClusterGroupsCSV(fullfile(ksDir, 'cluster_KSLabel.tsv'));
        cids_cgs                = spikeStructure.cids;
        cgs                     = spikeStructure.cgs;
        if numel(cids_ks) == numel(cids_cgs)
            good = 1;
        else
            good = 0;
        end
else
    good = -1;
%     error('KS label file not found at %s', fullfile(ksDir, 'cluster_KSLabel.tsv'));
end
end
