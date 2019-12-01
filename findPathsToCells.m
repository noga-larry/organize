function paths = findPathsToCells (supPath,task_info,lines)

names =  {task_info(lines).save_name};
paths = cellfun(@(c)[supPath '\' c '.mat'],names,'uni',false);


