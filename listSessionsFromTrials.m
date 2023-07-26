function task_info = listSessionsFromTrials(supDirectory,prefix)


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



counter = 1;
for s = 1:length(prefix)
    curr_prefix = prefix{s};
    dirFrom = [supDirectory '\' monkeyName(curr_prefix(1:2)) '\' curr_prefix '\'];
    files = dir(dirFrom); files = files (3:end);
    
    numTrials = cellfun(@str2double,regexp({files.name},'(?<=(a\.))[0-9]*','match'),'UniformOutput',false);
    numTrials = sort([numTrials{:}]);
    if isempty(numTrials)
        continue
    end
    data_raw = readcxdata([dirFrom '\'  prefix{s} 'a' sprintf('.%04d',numTrials(1))]);
    if isempty(data_raw.trialname)
        continue
    end
    taskBefore = getTrialType(data_raw);
    thetaBefore = double(data_raw.key.iPosTheta/1000);
    fb = 1;
    for ii=1:length(numTrials)
        data_raw = readcxdata(  [dirFrom '\'  prefix{s} 'a' sprintf('.%04d',numTrials(ii))]);
        taskCurrent = getTrialType(data_raw);
        thetaCurrent = double(data_raw.key.iPosTheta/1000);
        if ~strcmp(taskBefore,taskCurrent) || ~(thetaCurrent==thetaBefore) || (ii==length(numTrials))
            if ~strcmp(taskBefore,taskCurrent) || ~(thetaCurrent==thetaBefore)
                fe = numTrials(ii)-1;
            elseif (numTrials(ii)==length(numTrials))
                fe = numTrials(ii);
            end
            task_info(counter).session = prefix{s};
            task_info(counter).task = taskBefore;
            task_info(counter).file_begin = fb;
            task_info(counter).file_end = fe;
            task_info(counter).trial_type = 'a'; 
            task_info(counter).screen_rotation = thetaBefore; 
            task_info(counter).num_trials = fe-fb; 
            counter = counter+1;
            taskBefore = taskCurrent;
            thetaBefore = thetaCurrent;
            fb = fe+1;
        end
    end
end