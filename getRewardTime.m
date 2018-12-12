function rwd_time = getRewardTime( rwd_trace, trial_begin, trial_end )
% This function recieves the signal sent to the pump and return the time
% reward was delivered. 
% Inputs:       rwd_trace   Signal to pump (can be found in the trial's 
%                           extended data).
%               trial_begin Time in rwd_trace in which the trial begins.
%               trial_begin Time in rwd_trace in which the trial begins.
%               trial_end   Time in rwd_trace in which the trial ends.
% Outputs:                  Time in rwd_trace in which the reward delivery
%               rwd_time    begins.   
threshold = 1000;
rwd_delay = 1000; % assume the reward starts 1000 ms after the trials ends.
rwd = find(rwd_trace > threshold);
rwd(rwd<trial_begin)  = [];
rwd(rwd>(trial_end+rwd_delay))  = [];
rwd_time = min(rwd);

end

