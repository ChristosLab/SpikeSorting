external_packages = dir('External');
for i = 1:numel(external_packages)
    if ismember({external_packages(i).name}, {'.', '..'})
        continue
    elseif ~isempty(regexpi(external_packages(i).name, 'fieldtrip', 'once'))
        continue
%                 addpath(fullfile(external_packages(i).folder, external_packages(i).name))
%                 global ft_default
%                 ft_default.toolbox.signal = 'matlab';  % can be 'compat' or 'matlab'
%                 ft_default.toolbox.stats  = 'matlab';
%                 ft_default.toolbox.image  = 'matlab';
%                 ft_defaults % this sets up the FieldTrip path
    else
        addpath(genpath(fullfile(external_packages(i).folder, external_packages(i).name)));
    end
end
addpath(genpath('Utils'));
addpath('Analysis');
