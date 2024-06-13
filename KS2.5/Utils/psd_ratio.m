function psd_db_diff_per_channel = psd_ratio(psdPerChannel, f)
noise_f = 500;
ratio_f = [300, 2000; 2000, max(f)];
valid_idx_1 = find(mod(f, noise_f) .* (f > ratio_f(1, 1)) .* (f <= ratio_f(1, 2)));
valid_idx_2 = find(mod(f, noise_f) .* (f > ratio_f(2, 1)) .* (f <= ratio_f(2, 2)));
db_psdPerChannel = 10 * log10(psdPerChannel);
psd_db_diff_per_channel = mean(db_psdPerChannel(:, valid_idx_1), 2) - mean(db_psdPerChannel(:, valid_idx_2), 2);
end