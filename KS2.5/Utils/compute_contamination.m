function Q = compute_contamination(st)
if isempty(st)
    Q = 1;
    return
end
dt = 1/1000; % step size for CCG binning
[~, Qi, Q00, Q01, ~] = ccg(st, st, 500, dt); % % compute the auto-correlogram with 500 bins at 1ms bins
Q = min(Qi/(max(Q00, Q01))); % this is a measure of refractoriness
if isnan(Q)
    Q = 1;
end
end