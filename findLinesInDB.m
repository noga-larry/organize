function lines = findLinesInDB (task_info, req_params)

C = intersect([task_info.cell_ID],req_params.ID);
bool_ID = ismember([task_info.cell_ID],C);
bool_task = ~cellfun(@isempty,regexp({task_info.task},req_params.task))
bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},req_params.cell_type));
bool_grade = [task_info.grade] <= req_params.grade;
bool_nt = [task_info.num_trials] > req_params.num_trials;

lines = find(bool_task & bool_type & bool_grade & bool_ID .*bool_nt)

if req_params.remove_question_marks
   ind_qm = find(~cellfun(@isempty,regexp({task_info(lines).cell_type},'?')));
   lines(ind_qm) = [];
end
    


