function boolLick = isTrialWithLick(data,align_to, tb, te, ind)

%%%%%%%%%%%%%%%%%%

% NOT UPDATED!!!!

%%%%%%%%%%%%%%%%%%


% This function returns a boolian vector, indicating if a trial has a
% lick in it or not, at a time range before and after a
% trial event.
% Inputs: data                A data structer containing data on this
%                             specific cell.
%         allign_to           The trial event around which saccdes are
%                             looked for.
%         tb                  Time before the event (in ms).
%         te                  Time after the event (in ms).
% Output:  boolLick           boolLick(i)==1 iff there is a lick  in
%                             trial i in the specified time range.

if nargin==4
    ind = 1:length(data.trials);
elseif nargin>4
    assert(isnumeric(ind))
end

THRESHOLD = 1000;

boolLick = nan(1,length(ind));
for i=1:length(ind)
    t = ind(i);
    switch align_to
        case 'targetMovementOnset'
            tb_in_trial = data.trials(t).extended_trial_begin +...
                data.trials(t).movement_onset - tb;
            te_in_trial = data.trials(t).extended_trial_begin + ...
                data.trials(t).movement_onset + te;
        case 'cue'
            tb_in_trial = data.trials(t).extended_trial_begin + ...
                data.trials(t).cue_onset - tb;
            te_in_trial = data.trials(t).extended_trial_begin +...
                data.trials(t).cue_onset + te;
        case 'reward'
            tb_in_trial = ...
                data.trials(t).rwd_time_in_extended - tb;
            te_in_trial = ...
                data.trials(t).rwd_time_in_extended + te;
    end
    
    if te_in_trial>length(data.trials(t).lick)
        te_in_trial = length(data.trials(t).lick)
    end
    aligned_lick = data.trials(t).lick(tb_in_trial:te_in_trial);
    
    boolLick(i) = any(aligned_lick>THRESHOLD);
end
    
