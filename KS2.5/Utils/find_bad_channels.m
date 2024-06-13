function find_bad_channels(sessions, raw_lfp_dir, varargin)
p = inputParser;
p.addParameter('noise_color_sd_threshold', 3, @isnumeric);
p.parse(varargin{:});

noise_color_sd_threshold = p.Results.noise_color_sd_threshold;

for i_session = 1:numel(sessions)
    session_name = sessions(i_session).daq_folder.name(1:6);
    save_file    = fullfile(raw_lfp_dir, [session_name, '_bad_channels.mat']);
    if isfile(save_file)
        fprintf(1, '%s already exists.\n', save_file)
    else
        fprintf(1, 'Start zw_computeRawPSD on %s.\n', session_name);
        [psdPerChannel, f] = zw_computeRawPSD(sessions(i_session).ks_folder, 1);
        regress_out        = noise_color(psdPerChannel, f);
        ic = kmeans(regress_out', 2);
        % Populous cluster
        pop_ic = round(mean(ic));
        if mean(regress_out(1, ic == pop_ic)) <= mean(regress_out(1, ic ~= pop_ic))
            warning('Atypical noise color distribution, no bad channels labeled in %s', sessions(i_session).ks_folder)
        else
            
            noise_color_sd_threshold
        end
    end
end
end