function get_extended_data(data_dir_from, data_dir_to)
% This data adds feilds to the 'data' files created by the function
% get_data. The function collectes information from the extended fata that
% includes spikes and behavior that occured before and after the Maestro
% trial. This data is importat when analysing data that occured during
% reward delivery.  
% Inputs:   data_dir_from     Path to the folder in which trials are
%                             stored. The function assumes that the
%                             extended data is stored with in folder named
%                             "extend_trial" inside a folder with the
%                             session date.
%           data_dir_from     Path to the folder in which the 'data' files
%                             are stored. The function iterates over the
%                             files in this folder and resaves them with
%                             additional fields. 
% Added fields:   
%          .rwd_time          Time point within the extended trial in which
%                             reward is delivered. 
%          .extended_vVel     Hertical eye velocity, in arbitrary units. 
%          .extended_hVel     Vertical eye velocity, in arbitrary units. 
%          .extended_lick     Lick infra-red recordings
%          .extended_spike_times 
%                             Times of spikes within the extended trial
%         .extended_trial_begin
%                             Time point of Maesto trial beginning
%         .extended_trial_length
%                             Length of extended trial          
extended_spike_times = 10;
tasks_dir = dir(data_dir_to); tasks_dir = {tasks_dir(3:end).name};
% run over tasks
for tsk = 1 : length(tasks_dir)
    
    % subfolder from which to take cell mat file
    dir_to = [data_dir_to '\' tasks_dir{tsk}];
    files = dir(dir_to); files = {files(3:end).name};
    
    for c = 1:length(files)
        load([dir_to '\' files{c}])
        % get trials in data set
        trials = [data.trials.trial_num];
        for tr = 1: length (trials)
            try
                extended = importdata([data_dir_from  '\' data.info.session '\extend_trial\' data.trials(tr).maestro_name '.mat']);
                data.trials(tr).rwd_time = getRewardTime(extended.rwd,extended.trial_begin_ms,extended.trial_end_ms);
                data.trials(tr).extended_vVel = extended.eyev;
                data.trials(tr).extended_hVel = extended.eyeh;
                data.trials(tr).extended_lick = extended.lick;
                data.trials(tr).extended_spike_times = extended.sortedSpikes{data.info.electrode+(data.info.template-1)*extended_spike_times};
                data.trials(tr).extended_trial_begin = extended.trial_begin_ms;
                data.trials(tr).extended_trial_length = length(extended.eyev);
            catch ME
                if (strcmp(ME.identifier,'MATLAB:importdata:FileNotFound'))
                    warning(['Unable to find extended data for trial' data.trials(tr).maestro_name]);
                    data.trials(tr).rwd_time = nan;
                    data.trials(tr).extended_vVel = nan;
                    data.trials(tr).extended_hVel = nan;
                    data.trials(tr).extended_lick = nan;
                    data.trials(tr).extended_spike_times = nan;
                    data.trials(tr).extended_trial_begin = nan;
                    data.trials(tr).extended_trial_end = nan;
                    data.trials(tr).extended_trial_length = nan;
                end
                if (strcmp(ME.message,"Reference to non-existent field 'lick'."))
                    extended = importdata([data_dir_from  '\' data.info.session '\extend_trial\' data.trials(tr).maestro_name '.mat']);
                    data.trials(tr).rwd_time = getRewardTime(extended.rwd,extended.trial_begin_ms,extended.trial_end_ms);
                    data.trials(tr).extended_vVel = extended.eyev;
                    data.trials(tr).extended_hVel = extended.eyeh;
                    data.trials(tr).extended_lick = nan;
                    data.trials(tr).extended_spike_times = extended.sortedSpikes{data.info.electrode+(data.info.template-1)*total_electrode_number};
                    data.trials(tr).rwd_trace = extended.rwd;
                    data.trials(tr).extended_trial_begin = extended.trial_begin_ms;
                    data.trials(tr).extended_trial_end = extended.trial_end_ms;data.trials(tr).extended_trial_begin = extended.trial_begin_ms;
                    data.trials(tr).extended_trial_end = extended.trial_end_ms;
                    data.trials(tr).extended_trial_length = length(extended.eyev);
                end
            end
        end
        save([dir_to '\' files{c}], 'data')
        if mod(c,50)==0
            disp([num2str(c) '/' num2str(length(files))])
        end
    end
    
    disp([num2str(tsk) ' task finished'])
    
end

disp('Finished!')



end






