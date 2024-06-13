figure; hold on; 
plot(center_dist(1:100, 1:3:10)', '.-k')
plot(all_noise(randperm(size(all_noise, 1), 100), 1:3:10)', '.-r')
%%
sm_ = mahal(center_dist(:, 1:3:10), center_dist(:, 1:3:10));
om_ = mahal(all_noise(:, 1:3:10), center_dist(:, 1:3:10));
figure; histogram(log10(sm_), 'Normalization', 'pdf', 'BinWidth', 0.1); hold on; histogram(log10(om_), 'Normalization', 'pdf', 'BinWidth', 0.1)
sm_ = mahal(center_dist, center_dist);
om_ = mahal(all_noise, center_dist);
