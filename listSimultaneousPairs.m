function task_info = listSimultaneousPairs(task_info,req_params)

% listSimultaneousPairs - Add information about simultaneously recorded cells to task_info.
%
% This function adds a field 'cell_recorded_simultaneously' to the 'task_info' structure.
% The field contains the line numbers of cells that were recorded at the same time as the
% current cell. The function uses information from the 'session' and other relevant fields
% in 'task_info' to identify simultaneous recordings and excludes cells recorded on the same
% electrode.
%
% INPUTS:
%   task_info: A structure array containing information about recorded cells. Each element
%              of the structure array represents a cell and is expected to have fields like
%              'session', 'cell_ID', 'electrode', etc.
%   req_params: A structure that contains required parameters for identifying simultaneous
%               cell recordings.
%
% OUTPUTS:
%   task_info: The input 'task_info' structure with an additional field 'cell_recorded_simultaneously'
%              added to each cell's entry. This field contains the line numbers of cells that were
%              recorded simultaneously with the current cell.

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
                    & ~(task_info(lines(c)).electrode == task_info(lines(d)).electrode);

                listOfCells = [listOfCells lines(d)];
            end
            
        end
        
        task_info(lines(c)).cell_recorded_simultaneously = listOfCells;
    end
end