function [f_bvks, x_mesh_range] = ksdensity2d(x, bw, x_range, n_pts)
%Wrapper for MVKSDENSITY with N-D input data. Computes a mesh of pts
%according to x_range and n_pts supplied in input.
n_dim = numel(n_pts);
mesh_range = @(x_col, bw_col, x_range_col, n_pts) linspace(x_range_col(1) - bw_col, x_range_col(2) +bw_col, n_pts);
for i = 1:n_dim
    x_mesh_range{i} = mesh_range(x(:, i), bw(i), x_range(:, i), n_pts(i));
end
x_mesh = cell([1, n_dim]);
[x_mesh{:}] = ndgrid(x_mesh_range{:});
f_bvks = mvksdensity(x, cell2mat(cellfun(@(x) reshape(x, [numel(x), 1]), x_mesh, 'UniformOutput', false)), 'bandwidth', bw);
% [x1_mesh, x2_mesh] = ndgrid(x_mesh_range{:});
% f_bvks = mvksdensity(x, [reshape(x1_mesh, [numel(x1_mesh), 1]), reshape(x2_mesh, [numel(x2_mesh), 1])], 'bandwidth', bw);
f_bvks = reshape(f_bvks, n_pts);
end
