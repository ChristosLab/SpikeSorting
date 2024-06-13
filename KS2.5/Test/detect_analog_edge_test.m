fs = D.Header.sample_rate;
figure;
hold on 
plot([1/fs:1/fs:numel(out_d)/fs], out_d);
plot(onset_new/fs, 1/D.Header.channels(129).bit_volts, 'rd')
plot(offset_new/fs, 1/D.Header.channels(129).bit_volts, 'kd')
for i = 1:numel(offset_new)
    if [offset_new(i)- onset_new(i)]./fs < 0.55
        xlim([onset_new(i), offset_new(i)]./fs + [-.1, .1])
        drawnow
        pause
    end
end