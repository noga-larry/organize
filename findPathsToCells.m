function paths = findPathsToCells (supPath,task_info,lines)

supPath = [supPath '\' task_info(lines(1)).task '\'];
names =  {task_info(lines).save_name};
paths = cellfun(@(c)[supPath '\' c '.mat'],names,'uni',false);


