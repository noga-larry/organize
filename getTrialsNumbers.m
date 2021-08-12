function trial_nums = getTrialsNumbers(task_info,line)

% This function retuns a list of the trial numbers of a spicific cells (the 
% cell in line "line") or session. It gets them from task_info. 

fb = task_info(line).fb_after_sort;
fe = task_info(line).fe_after_sort;
if ~isnumeric(fb)
    fb = str2num(fb);
    fe = str2num(fe);
    trial_nums = [fb(1):fe(1) fb(2):fe(2)];
else
    trial_nums = fb:fe;
end
end