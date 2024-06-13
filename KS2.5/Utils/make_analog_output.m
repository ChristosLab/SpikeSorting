function [data, t] = make_analog_output(ao_mod_params)
mod_type = ao_mod_params.mod_type;
freq = ao_mod_params.freq;
amp = ao_mod_params.amp;
T = ao_mod_params.T;
if isfield(ao_mod_params, 'Rate')
    Rate = ao_mod_params.Rate;
else % Pilots were all done with 1000 Hz without explicit records
    Rate = 1000;
end
%
t = 1/Rate:(1/Rate):T;
switch mod_type
    case 'square'
        data = amp .* repmat([ones(Rate / freq / 2, 1); zeros(ao_mod_params.Rate / freq / 2, 1)], [T * freq, 1]);
    case 'sine'
        data = amp .* (sin(2* pi * freq .* t - pi/2)'  + 1)/2;
end

if  abs(data(end)) > 1e-4
    error('Incomplete cycle in analog output, aborting.')
end
end