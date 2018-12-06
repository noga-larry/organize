function get_data(task_info, dir_data_from, dir_data_to, monkey,focus_task)
% This function creates a data strucutre for each cell\session and saves
% it. It takes different Maestro files and gathers them according to a
% session DB. These structures are later used in almost all my
% functions.
% Note: This function is made to collect only basic trial informatio.
% However, additional feild can be added to the data strucutres in
% additional functions.

% Inputs:   task_info     A matlab data structure based on the session
%                         DB. Each row represents a session. Need to 
%                         contain the fields:
%            .task        Name of task in session
%            .date        Date of the session (string)
%            .file_begin  Numer of first trial in session (number)
%            .file_end    Numer of first trial in last (number)
%           dir_data_from Path to Maestro files
%           dir_data_to   Path to a folder in which to save trials
%           monkey        Name of monkey
%           focus_task    Task we want to get data strucutes for

% Outputs:  The function create a directory named focus_task in 
% dir_data_to. In this folder it saves matlab structure, one for each 
% session of the task. These structures are named data and as a file in the
% name of the session date. Each data structure contains a field called 
% data.info that contain information taken from the session DB. It
% additionally contains the sessions trials in the field data.trials
%       .name               Trial name as written in Maestro
%       .trial_num          Number in Maestro
%       .trial_length       Duration of trial (ms)
%       .fail               Bollian: 1-if monkey failed trial, 0 - if
%                           monkey succeeded. 
%       .choice             Bollian: 1-if monkey chose the first target
%                          (should be the adaptove choice), 0-else.
%       .hPos               Horizonal position
%       .vPos               Vertical position
%       .hVel               Horizonal velocity
%       .vVel               Vertical velocity
%       .beginSaccade       Beginning time points for saccased and blinks.
%       .endSaccade         Ending time points for saccased and blinks.
%       .screen_rotation    Angle of screen rotation
%       .maestro_name       Name of Mastro file.
%       .movement_onset     Time of target movement onset (ms)

mkdir([dir_data_to '\' focus_task])
% sub folder in which to save trials
dir_to = [dir_data_to '\' focus_task];

CALIBRATE_VEL = 10.8826;
CALIBRATE_POS = 40;


ind_task = find(strcmp({task_info.task},focus_task));
fields = fieldnames(task_info);

% check if there aretwo sessions in the same day
session_dates = [task_info(ind_task).date];
repeats = zeros(size(session_dates));
for i = 1:length(session_dates)
repeats(i) = sum(session_dates(1:i)==session_dates(i));
end




for ii = 1:length(ind_task)
    
    % subfolder fro which to take trials
    dir_from = [dir_data_from '\' monkey(1:2) num2str(task_info(ind_task(ii)).date)];
    
    
    if ~ (7==exist(dir_from,'dir'))
        disp ('Trials are not in data folder')
        break
    end
    
    % take all info from excel sheet and sace it
    for f=1:numel(fields)
        data.info.(fields{f}) = task_info(ind_task(ii)).(fields{f});
    end
    
    
    % run over trials and save them
    files = dir (dir_from); files = files(3:end);
    f_b = task_info(ind_task(ii)).file_begin;
    f_e = task_info(ind_task(ii)).file_end;
    
    trial_num = f_b:f_e;
    
    % get trial info
    d = 0; % counting number of discarded trials
    for f = 1:length(trial_num)
        data_raw = readcxdata(  [dir_from '\' monkey(1:2) num2str(data.info.date) data.info.session sprintf('.%04d', trial_num(f))]);
        if isempty(data_raw.discard)
            data_raw.discard = 0;
        end
        
        if ~ data_raw.discard
            flags = data_raw.key.flags;
            data.trials(f-d).name = data_raw.trialname;
            data.trials(f-d).trial_num = trial_num(f);
            data.trials(f-d).trial_length = length(data_raw.data(1,:));
            data.trials(f-d).fail = ~bitget(flags, 3);
            data.trials(f-d).choice = bitget(flags, 5);
            % get behavior
            %  1: horizonal position
            %  2: vertical position
            %  3: horizonal velocity
            %  4: vertical velocity
            data.trials(f-d).hPos = data_raw.data(1,:)/CALIBRATE_POS;
            data.trials(f-d).vPos = data_raw.data(2,:)/CALIBRATE_POS;
            data.trials(f-d).hVel = data_raw.data(3,:)/CALIBRATE_VEL;
            data.trials(f-d).vVel = data_raw.data(4,:)/CALIBRATE_VEL;
            [beginSaccade, endSaccade] = getSaccades( data.trials(f-d).hVel, data.trials(f-d).vVel,...
                data_raw.blinks, data_raw.targets);
            data.trials(f-d).beginSaccade = beginSaccade;
            data.trials(f-d).endSaccade = endSaccade;
            data.trials(f-d).screen_rotation = double(data_raw.key.iPosTheta/1000);
            data.trials(f-d).maestro_name = files(trial_num(f)).name;
            data.trials(f-d).movement_onset = targetMovementOnOffSet(data_raw.targets);
           
        else
            d = d+1;
        end
        
    end

    
    % global sesson information
    data.info.directions = getDirections (data);
    
    % check screen rotation
    rotated = [data.trials.screen_rotation]~=0;
    if any(rotated)
        display (['screen is rotated:' num2str(data.info.date)])
        if max([data.trials.screen_rotation])~=min([data.trials.screen_rotation])
           display (['rotation change mid session:' num2str(data.info.date)]) 
        end
            
    end
    
    % name cell data file
    try
        name = num2str(task_info(ind_task(ii)).date);
        if repeats(ii)>1
            name = [name '_' num2str(repeats(ii))];
        end
        save([dir_to '\' name], 'data')
    catch
        beep
        if ~isempty(regexp(name,'?')) && (~discard_q)
            name (regexp(name,'?')) = [];
            save([dir_to '\' name], 'data')
        elseif ~isempty(regexp(name,'?')) && discard_q
            disp('File with ? discarded')
        else
            disp(['File name is invalid: ' num2str(task_info(ii).cell_ID) '_' num2str(task_info(ii).cell_type)])
            name = input ('Enter new file name or X to discard cell ');
            if ~ (name == 'X')
                save([dir_to '\' name], 'data')
            else
                disp('Discarded!')
            end
        end
    end
    clear data
    
    if mod(ii-ind_task(1),50)==0
        disp([num2str(ii-ind_task(1)) '/' num2str(length(ind_task))])
    end
    
    
end

disp('Finished!')



end

