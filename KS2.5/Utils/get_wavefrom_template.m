function [waveforms, max_site] = get_wavefrom_template(temps)
[~,max_site] = max(max(abs(temps),[],2),[],3);
templates_max = nan(size(temps,1),size(temps,2));
for curr_template = 1:size(temps,1)
    templates_max(curr_template,:) = ...
        temps(curr_template,:,max_site(curr_template));
end
waveforms = templates_max;
end