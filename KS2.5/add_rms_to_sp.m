clear
zw_setpath
sp_dir  = 'F:\Database\VanderbiltDAQ\spike_structure'; % Folder for storing filtered and downsampled LFP data
adc_input_directory = 'Z:\Development_project_2019\VanderbiltDAQ\raw_LFP';
sp_files = dir(fullfile(sp_dir, '*_sp.mat'));
for i = 1:numel(sp_files)
    load(fullfile(sp_files(i).folder, sp_files(i).name));
    hp_rms_file_path    = fullfile(adc_input_directory, ['*', sp_files(i).name(1:6), '*hp_RMS*']);
    hp_rms_file         = dir(hp_rms_file_path);
    if isempty(hp_rms_file)
        warning('No high-pass RMS file found at %s\n', hp_rms_file_path)
        sp.amp_rms = [];
        sp.amp_mad = [];
    else
        rms_structure = load(fullfile(hp_rms_file.folder, hp_rms_file.name));
        for i_clu = 1:numel(sp.cluster_tempAmps)
            sp.amp_rms(i_clu) = sp.cluster_tempAmps(i_clu)/rms_structure.rmsPerChannel(sp.cluster_chan(i_clu));
            sp.amp_mad(i_clu) = sp.cluster_tempAmps(i_clu)/rms_structure.madPerChannel(sp.cluster_chan(i_clu));
        end
    end
    save(fullfile(sp_files(i).folder, sp_files(i).name), 'sp');
end