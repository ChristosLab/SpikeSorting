function [templates, templateYs, templateXs, tempAmps] = get_templates(rez)
%Compute templates from PCs, without reversing the drift correction and
%whitening. Also computes each template's center of gravity along X and Y
%axes as well as raw amplitude.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rez.U = gather(rez.U);
rez.W = gather(rez.W);
xcoords = gather(rez.xcoords);
ycoords = gather(rez.ycoords);
spikeTemplates  = gather(rez.st3(:,2));
tempScalingAmps = gather(rez.st3(:,3));
templates = zeros(rez.ops.Nchan, size(rez.W,1), size(rez.W,2), 'single');
for iNN = 1:size(templates,3)
    templates(:,:,iNN) = squeeze(rez.U(:,iNN,:)) * squeeze(rez.W(:,iNN,:))';
end
templates = permute(templates, [3 2 1]); % now it's nTemplates x nSamples x nChannels

tempChanAmps = squeeze(max(templates,[],2))-squeeze(min(templates,[],2));
% The template amplitude is the amplitude of its largest channel (but see
% below for true tempAmps)
tempAmpsUnscaled = max(tempChanAmps,[],2);
% need to zero-out the potentially-many low values on distant channels ...
threshVals = tempAmpsUnscaled*0.3; 
tempChanAmps(bsxfun(@lt, tempChanAmps, threshVals)) = 0;
% ... in order to compute the depth as a center of mass
templateYs = sum(bsxfun(@times,tempChanAmps,ycoords'),2)./sum(tempChanAmps,2);
templateXs = sum(bsxfun(@times,tempChanAmps,xcoords'),2)./sum(tempChanAmps,2);

spikeAmps = tempAmpsUnscaled(spikeTemplates).*tempScalingAmps;
% take the average of all spike amps to get actual template amps (since
% tempScalingAmps are equal mean for all templates)
ta = clusterAverage(spikeTemplates, spikeAmps);
tids = unique(spikeTemplates);
tempAmps(tids+1) = ta; % because ta only has entries for templates that had at least one spike
tempAmps = tempAmps'; % for consistency, make first dimension template number



end