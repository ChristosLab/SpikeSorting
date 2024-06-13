function isi_dist = compute_isi_dist(sp, varargin)
default_n_ms_bins = 100;
p = inputParser;
addParameter(p,'n_ms_bins', default_n_ms_bins);
parse(p);
isi_dist = nan(numel(sp.cids), p.Results.n_ms_bins);
edges = [0:p.Results.n_ms_bins]./1000; %    millisecond to second
parse(p, varargin{:});
for i = 1:numel(sp.cids)
    st_ = sp.st(sp.clu == sp.cids(i));
    if isempty(st_)
        continue
    end
    isi_dist(i, :) = histcounts(diff(st_), edges, 'Normalization', 'probability');
end
end
