function out = ismember_locb_find(array1, array2)
[~, b] = ismember(array1, array2);
out = [find(all(b, 2)), b(all(b, 2), :)];
end