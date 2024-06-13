function [overlap_marginal, marginal_overlap, x_mesh_range] = ksdensity2d_overlap(x_cell, bw, x_range, n_pts, varargin)
%KSDENSITY2D_OVERLAP takes multiple sets of 2-D values, computes 1)
%"overlap_marginal": the marginal distributions of their 2-D PDF overlap
%and 2) "marginal_overlap": the PDF overlap of their marginal
%distributions.

% overlap_marginal: Uses KSDENSITY2D to compute multiple 2-D PDFs on the
% same domain grid; get their overlap by taking the minimum; and then
% margnalizes the overlap.
% marginal_overlap: Computes the marginal PDF along each 1-D domain, then
% get the overlap.

n_dim = numel(n_pts);
default_dim_required = 1:n_dim;
p = inputParser;
addParameter(p,'dim_required', default_dim_required);
parse(p, varargin{:});

overlap_marginal = cell([1, n_dim]);
marginal_overlap = cell([1, n_dim]);

for idx_cell = 1:numel(x_cell) %    Loops through sets of 2-D values
    %   Multi-variate PDF
    [f_mvks(:, :, idx_cell), x_mesh_range] = ksdensity2d(x_cell{idx_cell}, bw, x_range, n_pts);
    %   Uni-varaite PDF
    for idx_dim = p.Results.dim_required % Loops through domain dimensions
        f_uvks{idx_dim}(:, idx_cell) = ksdensity(x_cell{idx_cell}(:, idx_dim), x_mesh_range{idx_dim}, 'Bandwidth', bw(idx_dim));
    end
end
mv_overlap = min(f_mvks, [], numel(size(f_mvks)));
for idx_dim = p.Results.dim_required
    %   1) Marginalize overlap of 2-D PDFs
    %
    %   Find and record dimensions to integrate over
    integrate_dim = setxor(1:n_dim, idx_dim);
    %   Permute the matrix so that the marginal dimension is last
    mv_overlap_t  = permute(mv_overlap, [integrate_dim, idx_dim]);
    for idx_integrate_dim = integrate_dim
        %   Marginalize PDF via numeric integration, over dimension 1 by
        %   default
        mv_overlap_t = squeeze(trapz(x_mesh_range{idx_integrate_dim}, mv_overlap_t));
    end
    %
    %   2) Compute overlap of marginal PDFs
    uv_overlap                = min(f_uvks{idx_dim}, [] , numel(size(f_uvks{idx_dim})));
    %
    %   Return all marginal PDF as a column vector
    overlap_marginal{idx_dim} = reshape(mv_overlap_t, [numel(mv_overlap_t), 1]);
    marginal_overlap{idx_dim} = reshape(uv_overlap, [numel(uv_overlap), 1]);
end
end
