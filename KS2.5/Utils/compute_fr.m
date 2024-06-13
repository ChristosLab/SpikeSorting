function sp = compute_fr(sp)
field_names = {'n_st', 'fr'};
for field_name = field_names
    sp = remove_field_contains(sp, field_name);
end
dur           = max(sp.st) - min(sp.st);
sp.fr         = zeros(size(sp.cids))'; % Clusters along 1st dim
sp.n_st       = sp.fr;
sp.fr_overall = sp.fr;
for i = 1:numel(sp.cids)
    ts               = sp.st(sp.clu == sp.cids(i));
    sp.n_st(i)       = numel(ts);
    sp.fr_overall(i) = numel(ts)/dur;
    if numel(ts) < 2
        sp.fr(i) = 0;
    else
        sp.fr(i) = numel(ts)/double(max(ts) - min(ts));
    end
end
end