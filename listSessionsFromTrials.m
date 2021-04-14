function task_info = listSessionsFromTrials(supDirectory,prefix)
 
counter = 1;
for s = 1:length(prefix)
    dirFrom = [supDirectory '\' prefix{s} '\'];
    files = dir(dirFrom); files = files (3:end);
    
    numTrials = cellfun(@str2double,regexp({files.name},'(?<=a.)[0-9]*','match'),'UniformOutput',false);
    numTrials = max([numTrials{:}]);
    if numTrials==0
        continue
    end
    data_raw = readcxdata(  [dirFrom '\'  prefix{s} 'a' sprintf('.%04d',1)]);
    taskBefore = getTrialType(data_raw);
    thetaBefore = double(data_raw.key.iPosTheta/1000);
    fb = 1;
    for ii=1:numTrials
        data_raw = readcxdata(  [dirFrom '\'  prefix{s} 'a' sprintf('.%04d',ii)]);
        taskCurrent = getTrialType(data_raw);
        thetaCurrent = double(data_raw.key.iPosTheta/1000);
        if ~strcmp(taskBefore,taskCurrent) || ~(thetaCurrent==thetaBefore) || (ii==numTrials)
            if ~strcmp(taskBefore,taskCurrent) || ~(thetaCurrent==thetaBefore)
                fe = ii-1;
            elseif (ii==numTrials)
                fe = ii;
            end
            task_info(counter).session = prefix{s};
            task_info(counter).task = taskBefore;
            task_info(counter).file_begin = fb;
            task_info(counter).file_end = fe;
            task_info(counter).trial_type = 'a'; 
            task_info(counter).screen_rotation = thetaBefore; 
            counter = counter+1;
            taskBefore = taskCurrent;
            thetaBefore = thetaCurrent;
            fb = fe+1;
        end
    end
end