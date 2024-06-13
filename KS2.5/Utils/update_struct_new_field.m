function out_struct = update_struct_new_field(old_struct, new_struct)
out_struct = old_struct;
new_fieldnames = fieldnames(new_struct);
for i = 1:numel(new_fieldnames)
    if ~isfield(old_struct, new_fieldnames{i})
        out_struct.(new_fieldnames{i}) = new_struct.(new_fieldnames{i});
    end
end
end