function structure_in = remove_field_contains(structure_in, field_name_str)
field_names = fieldnames(structure_in);
field_names = field_names(cellfun(@(x) contains(x, field_name_str), field_names));
structure_in = rmfield(structure_in, field_names);
end