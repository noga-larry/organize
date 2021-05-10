function paths = findPathsToCells (supPath,task_info,lines)

tasks = {task_info(lines).task};
names =  {task_info(lines).save_name};
paths = cellfun(@(c,t)[supPath '\' t '\' c '.mat'],names,tasks,'uni',false);
