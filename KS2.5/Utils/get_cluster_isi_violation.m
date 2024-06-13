function sp = get_cluster_isi_violation(sp, varargin)
p = inputParser;
p.addParameter('t_censor', 0.0005);
p.addParameter('t_refractory', 0.002);
p.parse(varargin{:});
t_censor = p.Results.t_censor;
t_refractory = p.Results.t_refractory;

field_name = 'isi_violation';
sp = remove_field_contains(sp, field_name);
isi_violation = nan(size(sp.cids));
for i = 1:numel(sp.cids)
    st_ = sp.st(sp.clu == sp.cids(i));
    isi_violation(i) = compute_isi_violation(st_, t_censor, t_refractory);
end
sp.isi_violation = isi_violation;
end