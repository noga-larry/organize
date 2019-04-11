function match_o = getOutcome (data)
% This function finds all target reward probabilities in data based on
% trial names.
% Inputs:     data           A structure containig session trials
% Outputs:    match_o        Cell array in the length of data.trials
%                            containing the outcome of each trial. 
%                            1 if there was a reward and 0 if not 


expression = '(?<!N)R|NR'; 
[match_o,~] = regexp({data.trials.name},expression,'match','split','forceCellOutput');
match_o = reshape([match_o{:}],length(match_o{1}),length(match_o));
noReward = strcmp('NR',match_o);
Reward = strcmp(match_o,'R');

if any (~(noReward|Reward))
    warning(['Error: Could not determine trial outcome in cell ' num2str(data.info.cell_ID )])
end

match_o = Reward;