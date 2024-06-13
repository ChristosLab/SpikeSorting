function [stationary_flag, in_block_flag] = stationarityCheck2(fix_rate, varargin)
%STATIONARITYCHECK2 changes from STATIONARITYCHECK: 1) Dictates that the
%above-treshold moving avearge blocks need to be continuous; 2) Z-score
%trials need to extend continously from block ends (2-trial stop).
fix_rate = reshape(fix_rate, 1, numel(fix_rate));
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
%   Construct non-overlapping blocks and test for main effect of block idx
n_anova_block      = ceil(n_trial/block_size);
anova_y            = nan(block_size * n_anova_block, 1);
anova_y(1:n_trial) = fix_rate;
anova_y            = reshape(anova_y, block_size, n_anova_block);
[p, ~, ~]          = anova1(anova_y,'','off');
if p >= 0.05
    stationary_flag = true(size(fix_rate));
    in_block_flag   = true(size(fix_rate));
    return
end
%
%   Construct moving average blocks
moving_average_fix_rate = movmean(fix_rate, block_size);
max_rate                = max(moving_average_fix_rate);
n_block                 = numel(moving_average_fix_rate);
%   Find stable blocks
thresholded_blocks = find(moving_average_fix_rate > average_threshold * max_rate);
in_block_flag      = false(size(moving_average_fix_rate));
for i = 1:numel(thresholded_blocks)
    trial_in_consecutive_blocks = max(1, thresholded_blocks(i) - ceil((block_size - 1)/2)):min(n_block, thresholded_blocks(i) + floor((block_size - 1)/2));
    in_block_flag(trial_in_consecutive_blocks) = true;
end
%   Find edges of consecutive blocks
block_on           = find(diff(in_block_flag) == 1) + 1;
if in_block_flag(1)   == 1
    block_on  = [1, block_on];
end
block_off          = find(diff(in_block_flag) == -1);
if in_block_flag(end) == 1
    block_off = [block_off, n_block];
end
%   Characterize trials in stable blocks
stable_mean = mean(fix_rate(in_block_flag));
stable_std  = std(fix_rate(in_block_flag));
%   Find 2 consecutive trials below threshold as another bounding condition
stationary_flag                   = false(size(in_block_flag));
trial_below_threshold             = (fix_rate - stable_mean) < -z_threhold * stable_std;
consecutive_trial_below_threshold = trial_below_threshold(2:end) .* trial_below_threshold(1:(end - 1));
for i = 1:numel(block_on)
    left_edge  = find(consecutive_trial_below_threshold(1:(block_on(i) - 1)), 1, 'last') + 2;
    if isempty(left_edge)
        left_edge = 1;
    end
    right_edge = find(consecutive_trial_below_threshold((block_off(i) + 1):end), 1, 'first') - 1 + block_off(i);
    if isempty(right_edge)
        right_edge = numel(stationary_flag);
    end
    stationary_flag(left_edge:right_edge) = true;
end
end