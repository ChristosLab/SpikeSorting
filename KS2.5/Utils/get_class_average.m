function [classes, class_average, class_n] = get_class_average(class_seq, data_in, mask_in, varargin)
% class_seq: 1-by-n_trial
% data_in  : n_neuron-by-n_trial
% mask_in  : n_neuron-by-n_trial
sz_class_seq = size(class_seq);
sz_data_in   = size(data_in);
sz_mask_in   = size(mask_in);
assert(sz_class_seq(2) == prod(sz_class_seq), '"class_seq" size needs to be 1-by-n_trial');
assert(sz_data_in(2) == sz_class_seq(2), '"data_in" size needs to be n_neuron-by-n_trial');
assert(all(sz_mask_in == sz_data_in), '"mask_in" size needs to be n_neuron-by-n_trial');
if numel(varargin) > 0
    classes       = sort(varargin{1});
    [~, class_idx_seq] = ismember(class_seq, classes);
    class_idx_seq = class_idx_seq';
else
    [classes, ~, class_idx_seq] = unique(class_seq);
end


classes_to_match          = zeros([1, 1, numel(classes)]);
classes_to_match(1, 1, :) = 1:numel(classes);
class_n = squeeze(sum((class_idx_seq' .* mask_in) == classes_to_match, 2));
class_average = full(sparse(repmat([1:size(data_in, 1)]', [1, numel(class_idx_seq)]), repmat(class_idx_seq', [size(data_in, 1), 1]), data_in .* mask_in))./class_n;
end