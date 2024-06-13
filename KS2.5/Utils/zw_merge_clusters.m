function sp = zw_merge_clusters(sp, varargin)
% ZW_MERGE_CLUSTERS takes the raw kilosort 2.5 output, compute an
% adjancency matrix for cluster pairs, merge clusters, recompute cluster
% parameters, weed out low firing clusters and re-index for output.
%%
p = inputParser;
p.addParameter('fr_treshold', 0.1);
p.parse(varargin{:});
fr_treshold = p.Results.fr_treshold;
%%  Load data
sp = zw_templatePositionsAmplitudes(sp);
sp = compute_cluster_metrics(sp);
%%  Compute adjancency matrix
%   ACG similarity
sp.acg_corr_matrix = compute_acg_corr(sp);
%   Estimated source distance
sp.distance_matrix = compute_xy_distance(sp);
%   Waveform similarity
sp.adj_matrix      = (sp.similar_clusters >= 0.8) .* (sp.acg_corr_matrix >= 0.9) .* (abs(sp.distance_matrix) <= 50);
%   Amplitude-time overlap
sp.adj_matrix      = and_amplitude_overlap_matrix(sp, sp.adj_matrix, 0.6);
idx_unmerged      = conncomp(graph(sp.adj_matrix), 'OutputForm', 'vector');
%%  Intermediate reassignment of clusters
sp                 = merge_cids(sp, idx_unmerged);
sp                 = compute_cluster_metrics(sp);
idx_to_remove_fr   = or(logical(sp.fr < fr_treshold), logical(sp.fr_overall < fr_treshold/4));
idx_to_remove_cgs  = sp.cgs' == 0;
idx_unmerged       = 1:numel(sp.cids); % No-merge default
idx_unmerged(idx_to_remove_fr | idx_to_remove_cgs) = 0; %   Dummy code 0 for unwanted clusters
sp                 = merge_cids(sp, idx_unmerged); % Use merge to clean unwanted clusters
sp                 = compute_cluster_metrics(sp);
%%  Re-populate parameters
% sp = compute_cluster_metrics(sp);
% sp_new = update_struct_new_field(sp_new, sp);
fprintf(1, 'Clusters merged.\n')
end
%%
function sp_new = merge_cids(sp, idx_unmerged)
sp_new = sp;
sp_new.cids = unique(idx_unmerged); % creates new 1-indexed cids
sp_new.clu  = idx_unmerged(ismember_locb(sp.clu, sp.cids));
sp_new.cids = sp_new.cids(sp_new.cids > 0);
% Re-assign cgs and ks_label
sp_new.cgs  = nan(size(sp_new.cids));
sp_new.ks_label  = nan(size(sp_new.cids));
for i = 1:numel(sp_new.cids)
    % Cluster merged with noise is noise
    sp_new.cgs(i) = min(sp.cgs(idx_unmerged == sp_new.cids(i)));
    % Cluster merged with MUA is MUA
    sp_new.ks_label(i) = min(sp.ks_label(idx_unmerged == sp_new.cids(i)));    
end
end
%%
function out = nonzero_mean(in, varargin)
out = mean(in(find(in)), varargin{:});
end