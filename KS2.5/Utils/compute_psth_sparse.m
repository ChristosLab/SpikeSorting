function [psth, t_centers] = compute_psth_sparse(MatData, bin_width, step, t_range, statecode_threshold, varargin)
p = inputParser;
addParameter(p, "align_event", 'photodiode_on_event', @ischar);
p.parse(varargin{:});
align_event = p.Results.align_event;
t_shift = arrayfun(@(x) [double(x.(align_event))/MatData.sample_rate, nan * find(isempty(x.(align_event)))], MatData.trials);
target_trials = find([MatData.trials.Statecode] >= statecode_threshold);
%   Find ss size
for j = 1:numel(MatData.trials)
   ss_size = size(MatData.trials(j).ss);
   if all(ss_size)
       break
   end
end
%   Find staionary trials
stationary_mask = nan([numel(MatData.trials), ss_size(2)]);
if isfield(MatData, 'stationary')
    stationary_mask(MatData.stationary') = 1;
end

%   Find psth size
[sample_psth, t_centers] = zw_spike_time_to_psth([], bin_width, step, t_range);
%
psth        = nan([numel(MatData.trials), ss_size(2), numel(sample_psth)]);
for j = 1:numel(MatData.trials)
    if ~ismember(j, target_trials)
        continue
    end
    ss = MatData.trials(j).ss;
    for k = 1:ss_size(2)
        st = find(ss(:, k))/MatData.sample_rate;
        psth(j, k, :) = zw_spike_time_to_psth(st, bin_width, step, t_range + t_shift(j));
    end
end
psth = psth .* stationary_mask;
end
