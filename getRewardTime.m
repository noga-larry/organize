function rwdTime = getRewardTime( rwdTrace, trialBegin, trialEnd )
% getRewardTime - Find the time when the reward was delivered based on the pump signal.
%
% This function receives the signal sent to the pump and returns the time when the
% reward was delivered. It searches for signal peaks in the 'rwdTrace' between the
% 'trialBegin' and 'trialEnd' time points and identifies the first peak above a
% threshold value ('THRESHOLD') as the reward delivery time.
%
% INPUTS:
%   rwdTrace: Signal to the pump, which can be found in the trial's extended data.
%   trialBegin: Time in 'rwdTrace' when the trial begins.
%   trialEnd: Time in 'rwdTrace' when the trial ends.
%
% OUTPUTS:
%   rwdTime: The time in 'rwdTrace' when the reward delivery begins.

THRESHOLD = 1000;
RWD_DELAY = 1000; % assume the reward starts 1000 ms after the trials ends.
rwd = find(rwdTrace > THRESHOLD);
rwd(rwd<trialBegin)  = [];
rwd(rwd>(trialEnd+RWD_DELAY))  = [];
rwdTime = min(rwd);

end

