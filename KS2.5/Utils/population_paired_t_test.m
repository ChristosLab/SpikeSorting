function [classes, class_average, class_n] = population_paired_t_test(data_in_1, data_in_2, mask_in, varargin)
% data_in_1  : n_neuron-by-n_trial
% data_in_2  : n_neuron-by-n_trial
% mask_in    : n_neuron-by-n_trial
sz_data_in_1   = size(data_in_1);
sz_data_in_2   = size(data_in_2);
sz_mask_in     = size(mask_in);
assert(all(sz_data_in_1 == sz_data_in_2), '"data_in_1" and "data_in_2" sizes need to match');
assert(all(sz_mask_in == sz_data_in_1), '"mask_in" size needs to be n_neuron-by-n_trial');




class_average = full(sparse(repmat([1:size(data_in, 1)]', [1, numel(class_idx_seq)]), repmat(class_idx_seq', [size(data_in, 1), 1]), data_in .* mask_in))./class_n;
end