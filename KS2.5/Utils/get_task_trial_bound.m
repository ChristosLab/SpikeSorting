function bound_dur = get_task_trial_bound(AllData, varargin)
% Get the time duration in seconds to be assigned to a trial around the
% photodiode event, given the trial type.
default_padding_dur = 0;
p = inputParser;
addParameter(p, 'padding_dur', default_padding_dur);
parse(p, varargin{:});
padding_dur = p.Results.padding_dur;
task_type = detect_task_type(AllData);
parameters = AllData.parameters;
switch task_type
    case 'odrdist'
        pre_photodiode_dur  = parameters.FixAquisition + parameters.fixationDuration;
        post_photodiode_dur = 2 * (parameters.stimulusDuration + parameters.delayDuration) + parameters.TargetAquisition + parameters.targetDuration + parameters.ITI_Correct;
    case {'odr', 'biasedodr', 'odr_opto'}
        pre_photodiode_dur  = parameters.FixAquisition + parameters.fixationDuration;
        post_photodiode_dur = parameters.stimulusDuration + parameters.delayDuration + parameters.TargetAquisition + parameters.targetDuration + parameters.ITI_Correct;
    case 'fix'
        pre_photodiode_dur  = 0;
        post_photodiode_dur = parameters.FixAquisition + parameters.fixationDuration + parameters.ITI_Correct;
        padding_dur         = 1;
end
bound_dur = [padding_dur, padding_dur] + [pre_photodiode_dur, post_photodiode_dur];
end