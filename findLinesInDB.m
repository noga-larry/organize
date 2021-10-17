function lines = findLinesInDB (task_info, req_params)


if isfield(req_params,'task')
    bool_task = ~cellfun(@isempty,regexp({task_info.task},req_params.task));
else
    bool_task = ones(1, length(task_info));
end

if isfield(req_params,'ID')
    C = intersect([task_info.cell_ID],req_params.ID);
    bool_ID = ismember([task_info.cell_ID],C);
else
    bool_ID = ones(1, length(task_info));
end

if iscell(req_params.cell_type)
    req_params.cell_type = cellArrayToOrRegexp(req_params.cell_type);
end

if isfield(req_params,'cell_type')
    bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},req_params.cell_type));
else
    bool_type = ones(1, length(task_info));
end

if isfield(req_params,'grade')
    bool_grade = [task_info.grade] <= req_params.grade;
else
    bool_grade = ones(1, length(task_info));
end

if isfield(req_params,'num_trials')
    bool_nt = [task_info.num_trials] > req_params.num_trials;
else
    bool_nt = ones(1, length(task_info));
end


if isfield(req_params,'session')
    bool_session = strcmp (req_params.session, {task_info.session});
else
    bool_session = ones(1, length(task_info));
end

if isfield(req_params,'monkey')
    bool_monkey = ~cellfun(@isempty,regexp({task_info.session},req_params.monkey(1:2)));
else
    bool_monkey = ones(1, length(task_info));
end

lines = find(bool_task & bool_type & bool_grade &...
    bool_monkey & bool_ID .*bool_nt.*bool_session);


% remove repeated cells
if ~(isfield(req_params,'remove_repeats')) | req_params.remove_repeats
    linesCellIDs = [task_info(lines).cell_ID];
    linesCellTypes = {task_info(lines).cell_type};
    [~,uniqueLines] = unique(linesCellIDs);
    uniqueLines = lines(uniqueLines);
    repeatedLines = setdiff(lines,uniqueLines);
    
    removeLines = [];
    for ii=1:length(repeatedLines)
        thisLine = repeatedLines(ii);
        ID = task_info(thisLine).cell_ID;
        type = task_info(thisLine).cell_type;
        sameCellLines = lines(find(linesCellIDs==ID & strcmp(linesCellTypes,type)));
        [~,indMax] = max([task_info(sameCellLines).num_trials]);
        removeLines = [removeLines, setdiff(sameCellLines,sameCellLines(indMax))];
        if (length(sameCellLines)-1)>0
            disp(['Removed ' num2str(length(sameCellLines)-1) ' repeats of cell ' num2str(ID)])
        end
    end
    
    lines =  setdiff(lines,removeLines);
end


if isfield(req_params,'remove_question_marks') & req_params.remove_question_marks
   ind_qm = find(~cellfun(@isempty,regexp({task_info(lines).cell_type},'?')));
   lines(ind_qm) = [];
end
    


