function [target_fr, target_trials] = get_firing_rate_sparse_2(MatData, target_samples, statecode_threshold, varargin)
p = inputParser;
addParameter(p, "align_event", 'photodiode_on_event', @ischar);
p.parse(varargin{:});
align_event = p.Results.align_event;
sample_shift = arrayfun(@(x) [double(x.(align_event)), nan * find(isempty(x.(align_event)))], MatData.trials);
statcode_mask = [MatData.trials.Statecode] >= statecode_threshold;
align_event_mask = cellfun(@(x) ~isempty(x), {MatData.trials.(align_event)});
target_trials = find(statcode_mask .* align_event_mask);
target_fr            = zeros(numel(MatData.cids), numel(target_trials));
trials               = MatData.trials(target_trials);
for j = 1:numel(trials)
    ss = trials(j).ss(target_samples + sample_shift(target_trials(j)), :);
    target_fr(:, j) = sum(ss, 1);
end
target_fr = target_fr/numel(target_samples) * MatData.sample_rate;
end
