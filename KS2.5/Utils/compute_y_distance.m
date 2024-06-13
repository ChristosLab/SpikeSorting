%%  Distance matrix of cluster depth estimated from 2D template
function distance_matrix = compute_y_distance(sp, varargin)
[spikeAmps, spikeDepths, templateYpos, tempAmps, tempsUnW, tempDur, tempPeakWF] = ...
    templatePositionsAmplitudes(sp.temps, sp.winv, sp.ycoords, sp.spikeTemplates, sp.tempScalingAmps);
distance_matrix = templateYpos - templateYpos';
end