function [mat_out, sort_order] = sort_center_of_mass(mat_in, varargin)
assert(ismatrix(mat_in));
if numel(varargin) > 0
    sort_dim = varargin{1};
else
    sort_dim = 1;
end
dims = 1:ndims(mat_in);
marginal_dim = setxor(dims, sort_dim);
mat_in = permute(mat_in, [sort_dim, marginal_dim]);
mat_in_sum = squeeze(sum(mat_in .* (1:size(mat_in, 2)), 2) ./ sum(mat_in, 2));
[~, sort_order] = sort(mat_in_sum);
mat_in(:)  = mat_in(sort_order, :);
sort_order = ipermute(sort_order, [sort_dim, marginal_dim]);
mat_out    = ipermute(mat_in, [sort_dim, marginal_dim]);
end