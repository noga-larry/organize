function [lines] = findCspkSspkPairs(task_info,req_params)

req_params.cell_type = 'PC cs';
linesCS = findLinesInDB (task_info, req_params);
req_params.cell_type = 'PC ss';
linesSS = findLinesInDB (task_info, req_params);

counter = 0;

for i=1:length(linesCS)
    ID = task_info(linesCS(i)).cell_ID;
    trialsCS = getTrialsNumbers(task_info,linesCS(i));
    sameCellLines = linesSS([task_info(linesSS).cell_ID]==ID); 
    for j=1:length(sameCellLines)
        trialsSS = getTrialsNumbers(task_info,sameCellLines(j));
        if length(intersect(trialsSS,trialsCS)) > req_params.num_trials
            counter = counter+1;
            lines(1,counter) = sameCellLines(j);
            lines(2,counter) = linesCS(i);
        end
    end
end


end