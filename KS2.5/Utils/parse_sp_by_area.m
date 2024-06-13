function [area_labels, sp_out] = parse_sp_by_area(sp)
area_hemi = cellfun(@(x, y) ['_', x, '_', y], sp.cluster_area, sp.cluster_hemisphere, 'UniformOutput', false);
[area_labels, ~, cluster_area] = unique(area_hemi);
areas = unique(cluster_area);
if numel(areas) == 1
    sp_out = sp;
    return;
end
for area_idx = 1:numel(areas)
    cluster_in_area = cluster_area == areas(area_idx);
    sp_temp = sp;
    sp_fields = fieldnames(sp);
    for i_field = 1:numel(sp_fields)
        if and(numel(sp.(sp_fields{i_field})) == numel(sp.cids), or(isnumeric(sp.(sp_fields{i_field})), iscell(sp.(sp_fields{i_field}))))
            sp_temp.(sp_fields{i_field}) = sp_temp.(sp_fields{i_field})(cluster_in_area);
        end
    end
    sp_out(area_idx) = sp_temp;
end
end