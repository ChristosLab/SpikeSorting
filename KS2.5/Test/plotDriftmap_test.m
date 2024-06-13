myKsDir = 'C:\Database\Development_project_2019\VanderbiltDAQ\Open Ephys\KS_out\ROS\ROS135_2023-02-23_12-21-56\1\kilosort3';
[spikeTimes, spikeAmps, spikeDepths, spikeSites] = ksDriftmap(myKsDir);
figure; plotDriftmap(spikeTimes, spikeAmps, spikeDepths);