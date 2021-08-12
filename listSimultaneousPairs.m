function task_info = listSimultaneousPairs(task_info,req_params)

% This function added a feild "cell_recorded_simultaneously" to task_info
% that contains the line numbers of cells recoded at the same time.
% Note: Will remove cells recorded on the same electrode.

sessions = uniqueRowsCA({task_info.session}');

for ii=1:length(sessions)
    req_params.session = sessions{ii};
    % lines in this session
    lines = findLinesInDB (task_info, req_params);
    
    for c = 1:length(lines)
        listOfCells = [];
        trial_num1 = getTrialsNumbers(task_info,lines(c));
        
        for d = 1:length(lines)
            trial_num2 = getTrialsNumbers(task_info,lines(d))
            
            if length(intersect(trial_num1,trial_num2)) >= req_params.num_trials...
                    & ~(task_info(lines(c)).cell_ID == task_info(lines(d)).cell_ID)...
                    & ~(task_info(lines(c)).electrode == task_info(lines(d)).electrode)

                listOfCells = [listOfCells lines(d)];
            end
            
        end
        
        task_info(lines(c)).cell_recorded_simultaneously = listOfCells;
    end
end