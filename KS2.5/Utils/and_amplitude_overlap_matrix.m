function similarity_matrix = and_amplitude_overlap_matrix(sp, similarity_matrix, overlap_threshold)
[spikeAmps] = ...
    templatePositionsAmplitudes(sp.temps, sp.winv, sp.ycoords, sp.spikeTemplates, sp.tempScalingAmps);
for i = 1:(size(similarity_matrix, 1) - 1)
    for j = (i + 1):size(similarity_matrix, 1)
        %   Operate only on similar pairs
        if similarity_matrix(i, j) > 0
            st_  = sp.st(ismember(sp.clu, sp.cids([i, j])));
            amp_ = spikeAmps(ismember(sp.clu, sp.cids([i, j])));
            st_1  = sp.st(sp.clu == sp.cids(i));
            st_2  = sp.st(sp.clu == sp.cids(j));
            amp_1 = spikeAmps(sp.clu == sp.cids(i));
            amp_2 = spikeAmps(sp.clu == sp.cids(j));
            x_cell = {[st_1, amp_1], [st_2, amp_2]};
            bw      = [200, nan]; % [seconds, OE unit]
            % Detrend each amplitude sequence and compute pooled std to be
            % the Gaussian kernel bandwidth
            bw(2) = pooled_detrended_std({amp_1, amp_2}, {st_1, st_2}); 
            x_range = [min(st_), max(st_); quantile(amp_, 0.01), quantile(amp_, 0.99)]';
            n_pts   = [100, 50];
            [overlap_marginal, marginal_overlap] = ksdensity2d_overlap(x_cell, bw, x_range, n_pts, 'dim_required', 1);
            similarity_matrix(i, j) = sum(min(overlap_marginal{1}, marginal_overlap{1}))/sum(marginal_overlap{1}) >= overlap_threshold;
            %   Keep matrix symmetric for consistency
            similarity_matrix(j, i) = similarity_matrix(i, j);
        end
    end
end
end
