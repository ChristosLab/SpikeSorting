function out = pooled_detrended_std(x_cell, t_cell)
numer = 0;
denom = 0;
for i = 1:numel(x_cell)
    numer = numer + detrend_var(x_cell{i}, t_cell{i}) * (numel(x_cell{i}) - 1);
    denom = denom + numel(x_cell{i}) - 1;
end
out = sqrt(numer/denom);
end
