function [psth, t_centers] = zw_spike_time_to_psth(st, bin_width, step, t_range)
if any(isnan(t_range))
    psth = nan;
    t_centers = nan;
    return
end
fine_step_scale = gcd(1000*bin_width, 1000*step);
fine_step = fine_step_scale/1000;
ratio_bin = 1000*bin_width/fine_step_scale;
ratio_step = 1000*step/fine_step_scale;
bin_edges = t_range(1):fine_step:t_range(2);
windows = (0:ratio_bin - 1) + (1:ratio_step:(numel(bin_edges) - 1))';
bin_edges = (t_range(1) - (bin_width - step)/2):fine_step:(t_range(2) + (bin_width - step)/2);
if nargout > 1
    bin_centers = bin_edges(1:end - 1) + diff(bin_edges)./2;
    t_centers   = sum(bin_centers(windows), 2)/size(windows, 2);
end
fine_spike_count = histcounts(st, bin_edges);
psth = sum(fine_spike_count(windows), 2)'/bin_width;
end