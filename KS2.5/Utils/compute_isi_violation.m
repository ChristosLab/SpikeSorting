function out = compute_isi_violation(st, t_censor, t_refractory)
if isempty(st)
    out = nan;
    return
end
isi = diff(st);
n_censor     = sum(isi < t_censor);
n_violation  = sum(isi < t_refractory);
n_total      = numel(st);
fr_total     = n_total/(max(st) - min(st));
fr_violation = (n_violation - n_censor)/(2 * n_total * (t_refractory - t_censor));
out          = fr_violation/fr_total;
end