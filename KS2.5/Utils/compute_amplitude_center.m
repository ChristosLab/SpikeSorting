function templateDepths = compute_amplitude_center(tempChanAmps, coords)
tempAmpsUnscaled = max(tempChanAmps,[],2);
threshVals = tempAmpsUnscaled*0.3; 
tempChanAmps(bsxfun(@lt, tempChanAmps, threshVals)) = 0;
templateDepths = sum(bsxfun(@times,tempChanAmps,coords'),2)./sum(tempChanAmps,2);
end