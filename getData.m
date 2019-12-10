function task_info = getData(task_info, sup_dir_from, sup_dir_to , lines, saccades_extraction)
% This function creates a data strucutre for each cell\session and saves
% it. It takes different Maestro files and gathers them according to a
% session DB. These structures are later used in almost all my
% functions.
% Note: This function is made to collect only basic trial information.
% However, additional feild can be added to the data strucutres by
% additional functions.

% Inputs:   task_info       A matlab data structure based on the session
%                           DB. Each row represents a session. Need to
%                           contain the fields:
%            .task          Name of task in session
%            .session       A string of the form 'al190430'.
%               For behavior only data:
%            .file_begin    Numer of first trial in session (number)
%            .file_end      Numer of first trial in last (number)
%              For neural data:
%            .fb_after_sort Numer of first trial in session (number), after
%                           sorting.
%            .fe_after_sort Numer of last trial in session (number), after
%                           sorting.
%            .electrode;    Electode number
%            .template;  %  Template number


%           sup_dir_from  Path to Maestro files
%           sup_dir_to    Path to a folder in which to save trials
%           lines         Line numbers in task_info to comstruct data
%                         structures for.
%           saccades_extraction
%                         Whether or not to look for saccades. if false,
%                         saccades will be taken from the mark1 and mark2
%                         fields in the Maestro file.

% Outputs:  The function creates a directory for each monkey and within it
% a directory for  each task in sup_dir_to. In this folder it saves matlab
% structure, one for each cell or session of the task. These structures are
% named data and as a file in the name of the session date or the cell ID
% and type. Each data structure contains a field called data.info that 
% contain information taken from the DB. It additionally contains the 
% trials in the field data.trials:
%       .name               Trial name as written in Maestro
%       .trial_length       Duration of trial (ms)
%       .fail               Bollian: 1-if monkey failed trial, 0 - if
%                           monkey succeeded.
%       .choice             Bollian: 1-if monkey chose the first target
%                          (should be the adaptive choice), 0-else.
%       .beginSaccade       Beginning time points for saccased and blinks.
%       .endSaccade         Ending time points for saccased and blinks.
%       .screen_rotation    Angle of screen rotation
%       .maestro_name       Name of Mastro file.
%       .movement_onset     Time of target movement onset (ms)
%       .rwd_time_in_extended
%                           Time of reward delivey (from the begining
%                           of the extended trial, ms)
%       For neural data:  
%       .spikes             Spike times (ms)
%       .extended_spike_times    
%                           Spike times in extended (ms)
%       For behavior only:
%       .hPos, .vPos, .hVel, .vVel
%                           behavior traces (caliberated)
% The function returns task_info with the additional feild saved_name
% which contains the name the structure for the line in the DB was saved
% under.It also creates a feild called 

total_electrode_number =10;
extended_spike_times = 10;
CALIBRATE_VEL = 10.8826;
CALIBRATE_POS = 40;


% check if there is also neural data, or behavior only

neuro_flag = isfield(task_info, 'cell_ID');

% Monkey names dictionary:
monkeyList =...
  {'albert',
    'chips',
    'bissli',
    'yoda',
    'reggie',
    'pluto',
    'imonkey',
    'xtra'};
monkeyName =  containers.Map(cellfun(@(x) x(1:2), monkeyList, 'un', 0),monkeyList);

fields = fieldnames(task_info);


tasks = uniqueRowsCA({task_info(lines).task}');
monkeys = uniqueRowsCA(cellfun(@(x) x(1:2),{task_info(lines).session},'UniformOutput',false)');
for ii=1:length(monkeys)
    for t = 1:length(tasks)
        dir_to = [sup_dir_to '\' monkeyName(monkeys{ii}) '\' tasks{t}];
        
        mkdir(dir_to);
        
    end
end


for ii = 1:length(lines)
    
    % subfolder from which to take trials
    dir_from = [sup_dir_from '\' monkeyName(task_info(lines(ii)).session(1:2)) '\' task_info(lines(ii)).session];
    
    
    if ~ (7==exist(dir_from,'dir'))
        disp ('Trials are not in data folder')
        continue
    end
    
    % take all info from excel sheet and save it
    for f=1:numel(fields)
        data.info.(fields{f}) = task_info(lines(ii)).(fields{f});
    end
    
    
    % run over trials and save them
    if neuro_flag
        f_b = task_info(lines(ii)).fb_after_sort;
        f_e = task_info(lines(ii)).fe_after_sort;
        if ~isnumeric(f_b)
            f_b = str2num(f_b);
            f_e = str2num(f_e);
            trial_num = [f_b(1):f_e(1) f_b(2):f_e(2)];
        else
            trial_num = f_b:f_e;
        end
        
        num_e = task_info(lines(ii)).electrode; % electode number
        num_t = task_info(lines(ii)).template;  % template number
        
    else
        f_b = task_info(lines(ii)).file_begin;
        f_e = task_info(lines(ii)).file_end;
        trial_num = f_b:f_e;
    end
    
    
    % type of task for targetMovementOnset
    if regexp(data.info.task,'pursuit|speed')
        trialType = 'pursuit';
    elseif regexp(data.info.task,'saccade')
        trialType = 'saccade';
    end
        
    
    % get trial info
    d = 0; % counting number of discarded trials
    for f = 1:length(trial_num)
        data_raw = readcxdata(  [dir_from '\'  data.info.session data.info.trial_type sprintf('.%04d', trial_num(f))]);
        
        discard = 0; 
        if data_raw.discard ==1 | any(data_raw.mark1==-1)| ~isempty(data_raw.marks);
            discard = 1;
        elseif isempty(data_raw.key)
            discard = 1
            disp(['Misses trial: ' dir_from '\'  data.info.session data.info.trial_type sprintf('.%04d', trial_num(f))])
        end
        if ~discard
            flags = data_raw.key.flags;
            data.trials(f-d).maestro_name = [data.info.session data.info.trial_type sprintf('.%04d', trial_num(f))];
            data.trials(f-d).name = data_raw.trialname;
            data.trials(f-d).trial_length = length(data_raw.data(1,:));
            data.trials(f-d).fail =  logical(~bitget(flags, 3));
            data.trials(f-d).choice =  logical(bitget(flags, 5));
            % get behavior
            %  1: horizonal position
            %  2: vertical position
            %  3: horizonal velocity
            %  4: vertical velocity
            
            
            data.trials(f-d).movement_onset = targetMovementOnOffSet(data_raw.targets, trialType);
            data.trials(f-d).cue_onset = data_raw.targets.on{1}(1);
            
            if saccades_extraction
                hVel = data_raw.data(3,:)/CALIBRATE_VEL;
                vVel = data_raw.data(4,:)/CALIBRATE_VEL;
                [beginSaccade, endSaccade] = getSaccades(hVel,vVel,...
                    data_raw.blinks, data_raw.targets, trialType);
                data.trials(f-d).beginSaccade = beginSaccade;
                data.trials(f-d).endSaccade = endSaccade;
            else
                data.trials(f-d).beginSaccade = data_raw.mark1;
                data.trials(f-d).endSaccade = data_raw.mark2;
            end
            
            data.trials(f-d).screen_rotation = double(data_raw.key.iPosTheta/1000);
            
            if neuro_flag
                try
                    extended = importdata([sup_dir_from  '\'  monkeyName(task_info(lines(ii)).session(1:2)) '\' data.info.session '\extend_trial\' ...
                        data.trials(f-d).maestro_name '.mat']);
                    data.trials(f-d).rwd_time_in_extended = extended.trial_end_ms;
                    data.trials(f-d).extended_spike_times = ...
                        extended.sortedSpikes{data.info.electrode+(data.info.template-1)*extended_spike_times};
                    data.trials(f-d).rwd_time_in_extended = extended.trial_end_ms;
                    
                catch
                    warning(['Extended data for ' data.trials(f-d).maestro_name ' not found']);
                    
                end
                
                
                data.trials(f-d).spike_times = data_raw.sortedSpikes{num_e+(num_t-1)*total_electrode_number};
                
            else
                % get behavior
                %  1: horizonal position
                %  2: vertical position
                %  3: horizonal velocity
                %  4: vertical velocity
                data.trials(f-d).hPos = data_raw.data(1,:)/CALIBRATE_POS;
                data.trials(f-d).vPos = data_raw.data(2,:)/CALIBRATE_POS;
                data.trials(f-d).hVel = data_raw.data(3,:)/CALIBRATE_VEL;
                data.trials(f-d).vVel = data_raw.data(4,:)/CALIBRATE_VEL;
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
            display (['screen is rotated:' num2str(data.info.session)])
        end
        if max([data.trials.screen_rotation])~=min([data.trials.screen_rotation])
            display (['rotation change mid session:' num2str(data.info.session)])
        end
        
    end
    
    % check that there are spikes
    
    if neuro_flag && isempty([data.trials.spike_times])
        disp (['No spikes in cell' num2str(data.info.cell_ID) ': cell discarded'])
        continue        
    end
    
    % name cell data file
    if neuro_flag
        name = [num2str(task_info(lines(ii)).cell_ID) ' ' task_info(lines(ii)).cell_type];
    else
        name = num2str(task_info(lines(ii)).session);

    end
    
    dir_to = [sup_dir_to '\' monkeyName(task_info(lines(ii)).session(1:2)) '\' task_info(lines(ii)).task];
    while exist([dir_to '\' name '.mat'], 'file')
        name = [name ' (1)'];
    end
    
    
    % sub folder in which to save trials
    name = strtrim(name); %remove redundent spaces
    try
        save([dir_to '\' name], 'data')
    catch
        beep
        if ~isempty(regexp(name,'?'))
            name (regexp(name,'?')) = '#';
            save([dir_to '\' name], 'data')
        else
            disp(['File name is invalid: ' num2str(task_info(lines(ii)).cell_ID) '_' num2str(task_info(lines(ii)).cell_type)])
            name = input ('Enter new file name or X to discard cell ');
            if ~ (name == 'X')
                save([dir_to '\' name], 'data')
            else
                disp('Discarded!')
            end
        end
    end
    
    % Create mata-data information structure:
    task_info(lines(ii)).save_name = name;
    task_info(lines(ii)).num_trials = length(data.trials);
    
    clear data
    
    if mod(ii,50)==0
        disp([num2str(ii) '\' num2str(length(lines))])
    end
    
end
disp('Finished!')



end

