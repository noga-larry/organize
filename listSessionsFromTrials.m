function task_info = listSessionsFromTrials(supDirectory,prefix)
 

for s = 1:length(prefix)
    dirFrom = [supDirectory '\' prefix{s} '\'];
    files = dir(dirFrom); files = files (3:end);
    numTrials = length(files);
  
    data_raw = readcxdata(  [dirFrom '\'  prefix{s} 'a' sprintf('.%04d',1)]);
    taskBefore = getTrialType(data_raw);
    fb = 1;
    for ii=1:numTrials
        data_raw = readcxdata(  [dirFrom '\'  prefix{s} 'a' sprintf('.%04d',ii)]);
        taskCurrent = getTrialType(data_raw);
        if ~strcmp(taskBefore,taskCurrent) || (ii==numTrials)
            if ~strcmp(taskBefore,taskCurrent)
                fe = ii-1;
            elseif (ii==numTrials)
                fe = ii;
            end
            task_info.session = prefix{s};
            task_info.task = taskBefore;
            task_info.file_begin = fb;
            task_info.file_end = fe;
            task_info.trial_type = 'a';
        end
    end
end