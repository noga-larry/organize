function lines = findLinesInDB (task_info, req_params)

bool_task = ~cellfun(@isempty,regexp({task_info.task},req_params.task));

if isfield(req_params,'ID')
    C = intersect([task_info.cell_ID],req_params.ID);
    bool_ID = ismember([task_info.cell_ID],C);
else
    bool_ID = ones(1, length(task_info));
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

lines = find(bool_task & bool_type & bool_grade & bool_ID .*bool_nt);

if isfield(req_params,'remove_question_marks') & req_params.remove_question_marks
   ind_qm = find(~cellfun(@isempty,regexp({task_info(lines).cell_type},'?')));
   lines(ind_qm) = [];
end
    


