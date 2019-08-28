function get_data(task_info, dir_data_from, dir_data_to, monkey, focus_task, cell_type)
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
%           cel_type      (Optional) type of cell to get data strucutes for

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

% check if there is also neural data, or behavior only

discard_q = 0; % whether or not to discard cells with '?' in their type
saccades_extraction = 1; % whether or not to look for saccades. if false,
%                    saccades will be taken from the mark1 and mark2 fields
%                    in the Maestro file.
total_electrode_number =10;

neuro_flag = isfield(task_info, 'cell_ID');

mkdir([dir_data_to '\' focus_task])
% sub folder in which to save trials
dir_to = [dir_data_to '\' focus_task];

bool_task = strcmp({task_info.task},focus_task);
bool_monkey = ~cellfun(@isempty,regexp({task_info.session},monkey(1:2)));
if exist('cell_type','var')
    bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},cell_type));
    ind_task = find(bool_task.*bool_monkey.*bool_type);
else
    ind_task = find(bool_task.*bool_monkey);
end


fields = fieldnames(task_info);


% check if there are two sessions in the same day - relevent only when
% there is no devition by cell ID
if ~neuro_flag
    session_dates = [task_info(ind_task).date];
    repeats = zeros(size(session_dates));
    for i = 1:length(session_dates)
        repeats(i) = sum(session_dates(1:i)==session_dates(i));
    end
end




for ii = 1:length(ind_task)
    % subfolder fro which to take trials
    session_date = num2str(task_info(ind_task(ii)).date);
    if length(session_date)<6 %important for Mati's FEF data
        session_date = ['0' session_date];
    end
    dir_from = [dir_data_from '\' monkey(1:2) session_date ];
    
    
    if ~ (7==exist(dir_from,'dir'))
        disp ('Trials are not in data folder')
        break
    end
    
    % take all info from excel sheet and save it
    for f=1:numel(fields)
        data.info.(fields{f}) = task_info(ind_task(ii)).(fields{f});
    end
    
    
    % run over trials and save them
    files = dir (dir_from); files = files(3:end);
    if neuro_flag
        f_b = task_info(ind_task(ii)).fb_after_sort;
        f_e = task_info(ind_task(ii)).fe_after_sort;
        if ~isnumeric(f_b)
            f_b = str2num(f_b);
            f_e = str2num(f_e);
            trial_num = [f_b(1):f_e(1) f_b(2):f_e(2)];
        else
            trial_num = f_b:f_e;
        end
        
        num_e = task_info(ind_task(ii)).electrode; % electode number
        num_t = task_info(ind_task(ii)).template;  % template number
        
    else
        f_b = task_info(ind_task(ii)).file_begin;
        f_e = task_info(ind_task(ii)).file_end;
        trial_num = f_b:f_e;
    end
    
    
    
    % get trial info
    d = 0; % counting number of discarded trials
    for f = 1:length(trial_num)
        data_raw = readcxdata(  [dir_from '\'  data.info.session data.info.trial_type sprintf('.%04d', trial_num(f))]);
        if isempty(data_raw.discard)
            data_raw.discard = 0;
        end
        if ~ data_raw.discard
            flags = data_raw.key.flags;
            data.trials(f-d).name = data_raw.trialname;
            data.trials(f-d).trial_length = length(data_raw.data(1,:));
            data.trials(f-d).fail = ~bitget(flags, 3);
            data.trials(f-d).choice = bitget(flags, 5);
            % get behavior
            %  1: horizonal position
            %  2: vertical position
            %  3: horizonal velocity
            %  4: vertical velocity
%             data.trials(f-d).hPos = data_raw.data(1,:)/CALIBRATE_POS;
%             data.trials(f-d).vPos = data_raw.data(2,:)/CALIBRATE_POS;
%             data.trials(f-d).hVel = data_raw.data(3,:)/CALIBRATE_VEL;
%             data.trials(f-d).vVel = data_raw.data(4,:)/CALIBRATE_VEL;
            if saccades_extraction 
                [beginSaccade, endSaccade] = getSaccades( data.trials(f-d).hVel, data.trials(f-d).vVel,...
                    data_raw.blinks, data_raw.targets);
                data.trials(f-d).beginSaccade = beginSaccade;
                data.trials(f-d).endSaccade = endSaccade;
            else
                data.trials(f-d).beginSaccade = data_raw.mark1;
                data.trials(f-d).endSaccade = data_raw.mark2;
            end
            
            
            data.trials(f-d).screen_rotation = double(data_raw.key.iPosTheta/1000);
            data.trials(f-d).maestro_name = files(trial_num(f)).name;
            data.trials(f-d).movement_onset = targetMovementOnOffSet(data_raw.targets);
            if neuro_flag
                data.trials(f-d).spike_times = data_raw.sortedSpikes{num_e+(num_t-1)*total_electrode_number};
            end
            
            
        else
            d = d+1;
        end
        
    end
    
   
    % check screen rotation
    rotated = [data.trials.screen_rotation]~=0;
    if any(rotated)
        if neuro_flag
            display (['screen is rotated:' num2str(data.info.cell_ID)])
        else
            display (['screen is rotated:' num2str(data.info.date)])
        end
        if max([data.trials.screen_rotation])~=min([data.trials.screen_rotation])
            display (['rotation change mid session:' num2str(data.info.date)])
        end
        
    end
    
    
    
    % name cell data file
    if neuro_flag
        name = [num2str(task_info(ind_task(ii)).cell_ID) task_info(ind_task(ii)).cell_type];
    else
        name = num2str(task_info(ind_task(ii)).date);
        if repeats(ii)>1
            name = [name '_' num2str(repeats(ii))];
        end
    end
    while exist([dir_data_to '\' focus_task '\' name '.mat'], 'file')
        name = [name '_i'];
    end
    try
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
    
    % Create mata-data information structure:
    task_DB(ii).name = name;
    task_DB(ii).date = session_date;
    task_DB(ii).num_trials = length(data.trials);
    if neuro_flag
        task_DB(ii).cell_ID = data.info.cell_ID;
        task_DB(ii).cell_type = data.info.cell_type;
        task_DB(ii).grade = data.info.grade;
    end
    clear data
    
    if mod(ii,50)==0
        disp([num2str(ii) '\' num2str(length(ind_task))])
    end
    
end
save ([dir_to '\task_DB'],'task_DB')
disp('Finished!')



end

