function pairs = findSameNeuronInTwoLineLists(task_info,lines1,lines2)


cell_IDs = [task_info.cell_ID];
counter = 1;
for i = 1:length(lines1)
    cur_cell_ID = task_info(lines1(i)).cell_ID;
    all_ind = find(cell_IDs==cur_cell_ID);
    ind_in_list = intersect(all_ind,lines2);
    for j = 1:length(ind_in_list)
        pairs(counter).line1 = lines1(i);
        pairs(counter).line2 = ind_in_list(j);
        
        assert(task_info(lines1(i)).cell_ID==task_info(ind_in_list(j)).cell_ID)
        
        pairs(counter).cell_ID = cur_cell_ID;
        
        pairs(counter).task1 = task_info(lines1(i)).task;
        pairs(counter).task2 = task_info(ind_in_list(j)).task;
        
        pairs(counter).cell_type = task_info(ind_in_list(j)).cell_type;
        
        counter = counter+1;
    end
    
end