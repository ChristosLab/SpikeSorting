function oe = align_analog_events(oe, analog_events, aux_events)
%%ALIGN_ANALOG_EVENTS
% Decoding channels in aux_events the same as Digital Inputs of the
% acquisition board See loadOE.m
adc_helper_channel_state   = 4;   %  ADC channel reporting adc events (e.g. laser)
session_time_channel_state = 3;   %  ADC channel for session on
trial_time_channel_state   = 2;   %  ADC channel for trial on
photodiode_channel_state   = 1;   %  ADC channel for cue on
%
if ~(isempty(oe.session_time_event) && isempty(oe.trial_time_event) && isempty(oe.photodiode_time_event) && isempty(oe.adc_helper_time_event))
    oe
    error('Trying to align aux events when digital events are also present.')
end
%
corr_r_thresh = 0.99;
matched_channel = [];
%   analog_events expected to contain only one channel, which is a
%   duplication of one of the aux_events
%   Find the aux channel with the same number of events
analog_event_count   = size(analog_events.time_sample, 1);
aux_event_count      = arrayfun(@(x) size(x.time_sample, 1), aux_events);
channels_to_check = find(aux_event_count == analog_event_count);
for i = 1:numel(channels_to_check)
    corr_r = corr(double(analog_events.time_sample), double(aux_events(channels_to_check(i)).time_sample));
    if all(diag(corr_r) > corr_r_thresh, 'all')
        matched_channel = channels_to_check(i);
    end
end
if isempty(matched_channel)
    oe
    error('No matched adc channels found.')
end
matched_aux_event_flat    = aux_events(matched_channel).time_sample(:);
matched_analog_event_flat = analog_events.time_sample(:);
offsets = matched_analog_event_flat - matched_aux_event_flat;
for i = setxor(1:numel(aux_events), matched_channel)
    current_aux_event_flat = aux_events(i).time_sample(:);
    [~, sync_event] = min(abs(current_aux_event_flat - matched_aux_event_flat'), [], 2);
    current_aux_event_flat = current_aux_event_flat + offsets(sync_event);
    aux_events(i).time_sample = reshape(current_aux_event_flat, size(aux_events(i).time_sample));
end
aux_events(matched_channel).time_sample = analog_events.time_sample;
oe.session_time_event    = aux_events(session_time_channel_state).time_sample;
oe.trial_time_event      = aux_events(trial_time_channel_state).time_sample;
oe.photodiode_time_event = aux_events(photodiode_channel_state).time_sample;
oe.adc_helper_time_event = aux_events(adc_helper_channel_state).time_sample;

end