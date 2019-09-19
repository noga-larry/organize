function paths = findPathsToCells (supPath,task_info,req_params)

lines = findLinesInDB (task_info, req_params);
names =  {task_info(lines).save_name};

paths = cellfun(@(c)[supPath '\' c '.mat'],names,'uni',false);


