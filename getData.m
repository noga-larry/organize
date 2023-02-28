function task_info = getData(dataSet, lines, varargin)
% This function creates a data strucutre for each cell\session and saves
% it. It takes different Maestro files and gathers them according to a
% session DB. These structures are later used in almost all my
% functions.
% Note: This function is made to collect only basic trial information.
% However, additional feild can be added to the data strucutres by
% additional functions.

% Inputs:
% dataSet    (string) The function will use this to upload the paths to the
%            folder in which to save the data and the task_info file. This
%            is done using "loadDBAndSpecifyDataPaths". task_info ia a
%            structure with the followinf fields:   


% task_info       A matlab data structure based on the session
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
%            .electrode;    Electode number (except the case of recordings
%                           with a single electrode - like Mati's data
%                           brain stem)
%            .template;  %  Template number


%           lines         Line numbers in task_info to construct data
%                         structures for.

% Optional Inputs: 

%          numElectrodes  Number of electrode used in recording, used to
%                         find the location of spike time data in the
%                         Maestro file. (Possible values 1, 5, 10. Defualt:
%                         5)
%          saccadesExtraction
%                         1 - recalculate saccade times from the behavior.
%                         0 - use the saccade times in the Maestro file
%                         (Defualt: 1).
%          extendedExist  1 - look for extended files (files that include
%                         the time after trial end).
%                         0 - do not look for them. (Defualt: 1).
%

%                         0 - use the saccade times in the Maestro file
%                         (Defualt: 1).
%          includeBehavior
%                         1 - save individual trial behavior
%                         0 - do not save it. (Defualt: 0).


% Outputs:
% The function creates a directory for each monkey and within it
% a directory for  each task in sup_dir_to. In this folder it saves matlab
% structure, one for each cell or session of the task. These structures are
% named data and as a file in the name of the session date or the cell ID
% and type. Each data structure contains a field called data.info that
% contain information taken from the DB. It additionally contains the
% trials in the field data.trials:
%       .maestro_name       Name of Mastro file.
%       .name               Trial name as written in Maestro
%       .trial_length       Duration of trial (ms)
%       .fail               Boolian: 1-if monkey failed trial, 0 - if
%                           monkey succeeded.
%       .choice             Boolian: 1-if monkey chose the first target
%                          (should be the adaptive choice), 0-else.
%       .movement_onset     Time of target movement onset (ms)
%       .cue_onset     Time of cue onset (ms)
%       .blinkBegin         Beginning time points for blinks.
%       .blinkEnd           Ending time points for blinks.
%       .beginSaccade       Beginning time points for saccased and blinks.
%       .endSaccade         Ending time points for saccased and blinks.
%       .screen_rotation    Angle of screen rotation
%       .rwd_time_in_extended
%                           Time of reward delivey (from the begining
%                           of the extended trial, ms)
%       For neural data:
%       .spikes             Spike times (ms)
%       .extended_spike_times
%                           Spike times in extended (ms)
%       For behavior data:
%       .hPos, .vPos, .hVel, .vVel
%                           behavior traces (caliberated)
% The field extended_caliberation contains information that can be usd to
% caliberate the extended data behavior:
%      .b_0                 Intercept values b_0(1) - horizontal; b_0(2) -
%                           vertical
%      .b_1                 Slop values b_1(1) - horizontal; b_1(2) -
%                           vertical
%      .R_squared           R_squared values R_squared (1) - horizontal;
%                           R_squared (2) - vertical
%      .nObservetions       Number od observation used to fit the models.
%
% The function returns task_info with the additional feild saved_name
% which contains the name the structure for the line in the DB was saved
% under.
%

p = inputParser;
defaultNumElectrodes = 5;
addOptional(p,'numElectrodes',defaultNumElectrodes,@isnumeric);
defaultSaccadesExtraction = true;
addOptional(p,'saccadesExtraction',defaultSaccadesExtraction,@islogical);
defaultExtendedExist = true;
addOptional(p,'extendedExist',defaultExtendedExist,@islogical);
defaultIncludeBehavior = false;
addOptional(p,'includeBehavior',defaultIncludeBehavior,@islogical);

parse(p,varargin{:})
saccadesExtraction = p.Results.saccadesExtraction;
totalElectrodeNumber = p.Results.numElectrodes;
extendedExist = p.Results.extendedExist;
includeBehavior = p.Results.includeBehavior;

CALIBRATE_VEL = 10.8826;
CALIBRATE_POS = 40;

BLINK_MARGIN = 100; %ms
REWARD_THRESHOLD = 1000;

WARNING_R_SQ_FOR_EXTENDED_BEHAV = 0.98;

[task_info,sup_dir_to, sup_dir_from] = loadDBAndSpecifyDataPaths(dataSet);

% check if there is also neural data, or behavior only

neuro_flag = isfield(task_info, 'cell_ID');
if ~neuro_flag
    extendedExist = false
end
% Monkey names dictionary:
monkeyList =...
    {'albert',
    'chips',
    'bissli',
    'yoda',
    'reggie',
    'pluto',
    'imonkey',
    'xtra',
    'golda'};
monkeyName =  containers.Map(cellfun(@(x) x(1:2), monkeyList, 'un', 0),monkeyList);

fields = fieldnames(task_info);

tasks = uniqueRowsCA({task_info(lines).task}');

for t = 1:length(tasks)
    dir_to = [sup_dir_to  '\' tasks{t}];
    mkdir(dir_to);
end

for ii = 1:length(lines)
    
    % subfolder from which to take trials
    dir_from = [sup_dir_from '\' monkeyName(task_info(lines(ii)).session(1:2)) '\' task_info(lines(ii)).session];
    
    
    if ~ (7==exist(dir_from,'dir'))
        disp ('Trials are not in data folder')
        continue
    end
    
    % If needed, verify that the cell was sorted
    if neuro_flag && isfield(task_info,'plex_sorted_file') && any(isnan(task_info(lines(ii)).plex_sorted_file))
        disp (['Cell was not sorted: ' num2str(task_info(lines(ii)).cell_ID)])
        task_info(lines(ii)).grade = 10;
        continue
    end
    
    % take all info from excel sheet and save it
    for f=1:numel(fields)
        data.info.(fields{f}) = task_info(lines(ii)).(fields{f});
    end
    data.info.monkey = monkeyName(task_info(lines(ii)).session(1:2));
      
    
    % run over trials and save them
    if neuro_flag
        trial_num = getTrialsNumbers(task_info,lines(ii));
        
        if totalElectrodeNumber>1
            num_e = task_info(lines(ii)).electrode; % electode number
            num_t = task_info(lines(ii)).template;  % template number
        else
            num_e = 1;
            num_t = task_info(lines(ii)).template;  % template number
        end
        
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
    else
        trialType = 'pursuit';
    end
    
    allTrialAreCorrectInDB = true;
    % get trial info
    d = 0; % counting number of discarded trials
    for f = 1:length(trial_num)
        
        data_raw = readcxdata(  [dir_from '\'  data.info.session data.info.trial_type...
            sprintf('.%04d', trial_num(f))]);
        
        discard = 0;
        if data_raw.discard ==1 | any(data_raw.mark1==-1)| ~isempty(data_raw.marks);
            discard = 1;
        elseif isempty(data_raw.key)
            discard = 1;
            disp(['Missing trial: ' dir_from '\'  data.info.session data.info.trial_type sprintf('.%04d', trial_num(f))])
        end
        
        if discard
            d = d+1;
            continue
        end
         
        thisTrialCorrectTaskInDB = verifyTrialTypeInDB(dataSet,data_raw.trialname,data.info.task);
         
        flags = data_raw.key.flags;
        data.trials(f-d).maestro_name = [data.info.session data.info.trial_type sprintf('.%04d', trial_num(f))];
        data.trials(f-d).name = data_raw.trialname;
        
        % Fix errors in vermis data base
        if strcmp(dataSet,'Vermis') & strcmp(data_raw.trialname,'45v20P75R')
            data.trials(f-d).name = 'd45v20P75R';
        elseif strcmp(dataSet,'Vermis') & strcmp(data_raw.trialname,'d225v20P725NR')
            data.trials(f-d).name = 'd225v20P75NR';
        end
        
        if ~thisTrialCorrectTaskInDB
            allTrialAreCorrectInDB = false;
            continue
        end
        
        data.trials(f-d).trial_length = length(data_raw.data(1,:));
        data.trials(f-d).fail =  logical(~bitget(flags, 3));
        data.trials(f-d).choice =  logical(bitget(flags, 5));
        % get behavior
        %  1: horizonal position
        %  2: vertical position
        %  3: horizonal velocity
        %  4: vertical velocity
        
        [targetOnset, targetOffset] = ...
            targetMovementOnOffSet(data_raw.targets, trialType);
        data.trials(f-d).movement_onset = targetOnset;
        data.trials(f-d).cue_onset = data_raw.targets.on{1}(1);
        
        data.trials(f-d).blinkBegin = max(1,data_raw.blinks(1:2:end));
        data.trials(f-d).blinkEnd = min(data_raw.blinks(2:2:end),data.trials(f-d).trial_length);
        
        
        if saccadesExtraction
            hVel = data_raw.data(3,:)/CALIBRATE_VEL;
            vVel = data_raw.data(4,:)/CALIBRATE_VEL;
            [beginSaccade, endSaccade] = getSaccades(hVel,vVel,...
                data_raw.blinks, targetOnset, targetOffset);
            data.trials(f-d).beginSaccade = beginSaccade;
            data.trials(f-d).endSaccade = endSaccade;
        else
            data.trials(f-d).beginSaccade = data_raw.mark1;
            data.trials(f-d).endSaccade = data_raw.mark2;
        end
        
        data.trials(f-d).screen_rotation = double(data_raw.key.iPosTheta/1000);
        
        if neuro_flag
            data.trials(f-d).spike_times = ...
                data_raw.sortedSpikes{num_e+(num_t-1)*totalElectrodeNumber};
        end
        
        if includeBehavior | ~neuro_flag
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
        
        if extendedExist
            try
                extended = importdata([sup_dir_from  '\'  monkeyName(task_info(lines(ii)).session(1:2)) '\' data.info.session '\extend_trial\' ...
                    data.trials(f-d).maestro_name '.mat']);
                
                data.trials(f-d).rwd_time_in_extended = extended.trial_end_ms;
                data.trials(f-d).previous_completed = any(extended.rwd(1:extended.trial_begin_ms) > REWARD_THRESHOLD);
                if neuro_flag
                    data.trials(f-d).extended_spike_times = ...
                        extended.sortedSpikes{data.info.electrode+(data.info.template-1)*totalElectrodeNumber};
                end
                
                % values for extended data caliberation
                
                exHraw = extended.eyeh(extended.trial_begin_ms:(extended.trial_end_ms-1));
                exVraw = extended.eyev(extended.trial_begin_ms:(extended.trial_end_ms-1));
                maeHraw = data_raw.data(1,:)/CALIBRATE_POS;
                maeVraw = data_raw.data(2,:)/CALIBRATE_POS;
                
                assert(length(exHraw)==length( data_raw.data(1,:)))
                
                nanBegin = max(data_raw.blinks(1:2:end)-BLINK_MARGIN,1);
                nanEnd = min(data_raw.blinks(2:2:end)+BLINK_MARGIN,length(maeVraw));
                
                exHraw = removesSaccades(exHraw,nanBegin,nanEnd);
                exVraw = removesSaccades(exVraw,nanBegin,nanEnd);
                maeHraw = removesSaccades(maeHraw,nanBegin,nanEnd);
                maeVraw = removesSaccades(maeVraw,nanBegin,nanEnd);
                
                extendedH{f-d} = exHraw';
                extendedV{f-d} = exVraw';
                maestroH{f-d} = maeHraw;
                maestroV{f-d} = maeVraw;
                
                
            catch
                warning(['Extended data for ' data.trials(f-d).maestro_name ' not found']);
                
            end
        end
    end
    
    
    
    if ~allTrialAreCorrectInDB
        disp(['Error in DB: ' name])
    end
    
    
    % caliberate extended behavior
    if extendedExist
        [b_0,b_1,R_squared,nObservetions] = caliberateExtendedBehavior...
            ([maestroH{:}],[maestroV{:}],[extendedH{:}],[extendedV{:}]);
        
        extended_behavior_fit = any(R_squared<WARNING_R_SQ_FOR_EXTENDED_BEHAV)...
            | nObservetions < 30000;
        if extended_behavior_fit
            warning(['Problem with extended behavior caliberation in cell %s: '...
                'R_squared = %d, %f.; nObservetions = %g'],num2str(data.info.cell_ID)...
                ,R_squared(1),R_squared(2),nObservetions)
        end
        
        data.extended_caliberation.nt = nObservetions;
        data.extended_caliberation.b_0 = b_0;
        data.extended_caliberation.b_1 = b_1;
        data.extended_caliberation.R_squared = R_squared;
    end
    
    % check screen rotation
    rotated = [data.trials.screen_rotation]~=0;
    if any(rotated)
        if neuro_flag
            display (['screen is rotated:' num2str(data.info.cell_ID)])
        else
            display (['screen is rotated:' num2str(data.info.session)])
        end
    end
    
    if max([data.trials.screen_rotation])~=min([data.trials.screen_rotation])
        if neuro_flag
            display (['rotation change mid session:' num2str(data.info.cell_ID)])
        else
            display (['rotation change mid session:' num2str(data.info.session)])
        end
    else
        task_info(lines(ii)).screen_rotation = data.trials(1).screen_rotation;
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
    
    dir_to = [sup_dir_to '\'  task_info(lines(ii)).task];
    
    name = strtrim(name); %remove redundent spaces
    
    if ~isempty(regexp(name,'?', 'once'))
        name (regexp(name,'?')) = '#';
    end
    
    while exist([dir_to '\' name '.mat'], 'file')
        name = [name ' (1)'];
    end
    

    
    % sub folder in which to save trials
    
    try
        save([dir_to '\' name], 'data')
    catch
        disp(['File name is invalid: ' num2str(task_info(lines(ii)).cell_ID) '_' num2str(task_info(lines(ii)).cell_type)])
        name = input ('Enter new file name or X to discard cell ');
        if ~ (name == 'X')
            save([dir_to '\' name], 'data')
        else
            disp('Discarded!')
        end
    end  
    
    
    % Create mata-data information structure:
    task_info(lines(ii)).save_name = name;
    task_info(lines(ii)).num_trials = length(data.trials);
    if extendedExist
        task_info(lines(ii)).extended_behavior_fit = extended_behavior_fit;
    end
    

    
    clear data extendedH extendedV maestroH maestroV
    
    if mod(ii,50)==0
        disp([num2str(ii) '\' num2str(length(lines))])
    end
    
    save([sup_dir_to '\task_info'],'task_info')
    
end
disp('Finished!')



end

