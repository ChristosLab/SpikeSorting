function ic_out = find_ic_by_row(mat_in)
%   Concatenate idx of columns row-by-row
ic_out = [];
for i = 1:size(mat_in, 1)
    ic = find(mat_in(i, :));
    ic_out = [ic_out, ic];
end
end
