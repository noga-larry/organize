function pairs = findPairs(task_info,lines1,lines2,num_trials)

pairs = [];
counter = 0;


for ii=1:length(lines1)
    simLines = task_info(lines1(ii)).cell_recorded_simultaneously;
    simLines = intersect(lines2,simLines);
    for jj = 1:length(simLines)
        
        fb1 = task_info(lines1(ii)).fb_after_sort;
        fe1 = task_info(lines1(ii)).fe_after_sort;
        fb2 = task_info(simLines(jj)).fb_after_sort;
        fe2 = task_info(simLines(jj)).fe_after_sort;
        if length(intersect(fb1:fe1,fb2:fe2))>= num_trials
            
            counter = counter +1;
            pairs(counter).cell1 = lines1(ii);
            pairs(counter).cell2 = simLines(jj);
            pairs(counter).task = task_info(simLines(jj)).task;
            pairs(counter).cell_ID1 = task_info(lines1(ii)).cell_ID;
            pairs(counter).cell_ID2 = task_info(simLines(jj)).cell_ID;
            
        end        
    end    
end



for ii=1:length(pairs)
    cellIDs(1,ii) = min([task_info(pairs(ii).cell1).cell_ID,...
        task_info(pairs(ii).cell2).cell_ID]);
    cellIDs(2,ii) = max([task_info(pairs(ii).cell1).cell_ID,...
        task_info(pairs(ii).cell2).cell_ID]);

end

[~,ind,~] = unique(cellIDs','rows');
pairs = pairs(ind);


% for ii =1:length(pairs)
%     if task_info(pairs(ii).cell1).direction_tuning ...
%             & task_info(pairs(ii).cell2).direction_tuning
%         pairs(ii).congruent = (task_info(pairs(ii).cell1).PD == task_info(pairs(ii).cell2).PD);
%     else
%         pairs(ii).congruent = -1;
%     end
%     
%     pairs(ii).PD1 = task_info(pairs(ii).cell1).PD;
%     pairs(ii).PD2 = task_info(pairs(ii).cell2).PD;
% end

