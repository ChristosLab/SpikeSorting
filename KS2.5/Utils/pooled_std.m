function out = pooled_std(x_cell)
numer = 0;
denom = 0;
for i = 1:numel(x_cell)
    numer = numer + var(x_cell{i}) * (numel(x_cell{i}) - 1);
    denom = denom + numel(x_cell{i}) - 1;
end
out = sqrt(numer/denom);
end
