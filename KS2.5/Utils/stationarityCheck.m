function [stationary_flag, in_block_flag] = stationarityCheck(fix_rate, varargin)
p = inputParser;
addParameter(p, 'block_size', 32)
addParameter(p, 'average_threshold', 0.5)
addParameter(p, 'z_threhold', 1)
parse(p, varargin{:});
block_size        = p.Results.block_size;
average_threshold = p.Results.average_threshold;
z_threhold        = p.Results.z_threhold;
n_trial           = numel(fix_rate);
%%
%   Construct non-overlapping blocks
n_anova_block = ceil(n_trial/block_size);
anova_y = nan(block_size * n_anova_block, 1);
anova_y(1:n_trial) = fix_rate;
anova_y = reshape(anova_y, block_size, n_anova_block);
[p, ~, ~] = anova1(anova_y,'','off');
if p >= 0.05
    stationary_flag = true(size(fix_rate));
    in_block_flag   = true(size(fix_rate));
    return
end
%
%   Construct moving average blocks
moving_average_fix_rate = movmean(fix_rate, block_size);
max_rate = max(moving_average_fix_rate);
n_block = numel(moving_average_fix_rate);
%   Find stable range
for last_block=  n_block: -1: 1
    if moving_average_fix_rate(last_block) > average_threshold * max_rate
        break
    end
end
for first_block= 1: last_block
    if moving_average_fix_rate(first_block) > average_threshold * max_rate
        break
    end
end
%   Characterize trials in stable blocks
in_block_flag         = false(size(moving_average_fix_rate));
trial_in_stable_block = max(1, first_block - ceil((block_size - 1)/2)):min(n_block, last_block + floor((block_size - 1)/2));
in_block_flag(trial_in_stable_block) = true;
stable_mean = mean(fix_rate(trial_in_stable_block));
stable_std  = std(fix_rate(trial_in_stable_block));
%   Find 2 consecutive trials above threshold as another bounding condition
trial_above_threshold             = (fix_rate - stable_mean) > -z_threhold * stable_std;
consecutive_trial_above_threshold = trial_above_threshold(2:end) .* trial_above_threshold(1:(end - 1));
above_threshold_flag               = zeros(size(in_block_flag));
above_threshold_flag(find(consecutive_trial_above_threshold, 1, 'first'):(find(consecutive_trial_above_threshold, 1, 'last')) + 1) = 1;
stationary_flag                   = or(above_treshold_flag, in_block_flag);
end