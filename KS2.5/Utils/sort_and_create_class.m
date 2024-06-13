function MatData_out = sort_and_create_class(MatData, n_class)
MatData_out.class = struct(zeros([0, n_class]));
class_trial_counter = zeros(1, n_class); % Keeps track of trials assigned to each class
if isempty(fieldnames(MatData.ntr))
    return
end
for i_trial = 1:numel(MatData.ntr)
    current_class_ = MatData.ntr(i_trial).Class;
    class_trial_counter(current_class_) = class_trial_counter(current_class_) + 1;
    MatData_out.class(current_class_).ntr(class_trial_counter(current_class_)) = MatData.ntr(i_trial);
end