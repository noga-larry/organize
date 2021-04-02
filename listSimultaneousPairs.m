function task_info = listSimultaneousPairs(task_info,req_params)

% This function added a feild "cell_recorded_simultaneously" to task_info
% that contains the line numbers of cells recoded at the same time.
% Note: Will remove cells recorded on the same electrode.

sessions = uniqueRowsCA({task_info.session}');

for ii=1:length(sessions)
    req_params.session = sessions{ii};
    lines = findLinesInDB (task_info, req_params);
    
    for c = 1:length(lines)
        listOfCells = [];
        fb1 = task_info(lines(c)).fb_after_sort;
        fe1 = task_info(lines(c)).fe_after_sort;
        trial1 = fb1:fe1;
        
        for d = 1:length(lines)
            fb2 = task_info(lines(d)).fb_after_sort;
            fe2 = task_info(lines(d)).fe_after_sort;
            trials2 = fb2:fe2;
            
            if length(intersect(trial1,trials2)) >= req_params.num_trials...
                    & ~(task_info(lines(c)).cell_ID == task_info(lines(d)).cell_ID)...
                    & ~(task_info(lines(c)).electrode == task_info(lines(d)).electrode)

                listOfCells = [listOfCells lines(d)];
            end
            
        end
        
        task_info(lines(c)).cell_recorded_simultaneously = listOfCells;
    end
end