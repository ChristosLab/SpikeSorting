function out = get_similar_pairs(similarity_matrix, similarity_threshold)
out = unique(similarity_matrix > similarity_threshold, 'rows', 'stable');
%   Omits all zero pairs
out = out(any(out, 2), :);
remove_subset = zeros(size(out, 1), 1);
for i = 1:size(out, 1)
    remove_subset(i) = sum(all(out(i, :) .* out == out(i, :), 2)) > 1;
end
out(find(remove_subset), :) = [];
end
