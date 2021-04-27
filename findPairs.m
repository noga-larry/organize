function pairs = findPairs(task_info,lines1,lines2,num_trials)

pairs = [];
counter = 0;


for ii=1:length(lines1)
    simoultaneusLines = task_info(lines1(ii)).cell_recorded_simultaneously;
    simoultaneusLines = intersect(lines2,simoultaneusLines);
    for jj = 1:length(simoultaneusLines)

        fb1 = task_info(lines1(ii)).fb_after_sort;
        fe1 = task_info(lines1(ii)).fe_after_sort;
        if ~isnumeric(fb1)
            fb1 = str2num(fb1);
            fe1 = str2num(fe1);
            trial_num1 = [fb1(1):fe1(1) fb1(2):fe1(2)];
        else
            trial_num1 = fb1:fe1;
        end
        fb2 = task_info(simoultaneusLines(jj)).fb_after_sort;
        fe2 = task_info(simoultaneusLines(jj)).fe_after_sort;

        if ~isnumeric(fb2)
            fb2 = str2num(fb2);
            fe2 = str2num(fe2);
            trial_num2 = [fb2(1):fe2(1) fb2(2):fe2(2)];
        else
            trial_num2 = fb2:fe2;
        end
        if length(intersect(trial_num1,trial_num2))>= num_trials
            
            counter = counter +1;
            pairs(counter).cell1 = lines1(ii);
            pairs(counter).cell2 = simoultaneusLines(jj);
            pairs(counter).task = task_info(simoultaneusLines(jj)).task;
            pairs(counter).cell_ID1 = task_info(lines1(ii)).cell_ID;
            pairs(counter).cell_ID2 = task_info(simoultaneusLines(jj)).cell_ID;
            pairs(counter).cell_type1 = task_info(lines1(ii)).cell_type;
            pairs(counter).cell_type2 = task_info(simoultaneusLines(jj)).cell_type;
            
        end        
    end    
end



for ii=1:length(pairs)
    pairLines(1,ii) = min([pairs(ii).cell1, pairs(ii).cell2]);
    pairLines(2,ii) = max([pairs(ii).cell1, pairs(ii).cell2]);
end

[~,ind,~] = unique(pairLines','rows');


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

