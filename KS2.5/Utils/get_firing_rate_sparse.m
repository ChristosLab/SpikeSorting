function [target_fr, target_trials] = get_firing_rate_sparse(MatData, target_samples, statecode_threshold, varargin)
p = inputParser;
addParameter(p, "sample_shift", zeros([numel(MatData.trials), 1]), @isnumeric);
p.parse(varargin{:});
sample_shift = p.Results.sample_shift;
target_trials        = find([MatData.trials.Statecode] >= statecode_threshold);
target_fr            = zeros(numel(MatData.cids), numel(target_trials));
trials               = MatData.trials(target_trials);
for j = 1:numel(trials)
    ss = trials(j).ss(target_samples + sample_shift(target_trials(j)), :);
    target_fr(:, j) = sum(ss, 1);
end
target_fr = target_fr/numel(target_samples) * MatData.sample_rate;
end
