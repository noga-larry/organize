function match_o = getOutcome (data,ind,varargin)
% This function finds all target reward probabilities in data based on
% trial names.
% Inputs:     data           A structure containig session trials
% Outputs:    match_o        Cell array in the length of data.trials
%                            containing the outcome of each trial. 
%                            1 if there was a reward and 0 if not 

if nargin==1
    ind=1:length(data.trials);
elseif nargin>2
    assert(isnumeric(ind))
end


if isempty(ind)
    disp('Empty set of indices!')
    match_o = nan;
    return
end

p = inputParser;
defaultOmitNonIndexed = false;
addOptional(p,'omitNonIndexed',defaultOmitNonIndexed,@islogical);

parse(p,varargin{:})
omitNonIndexed = p.Results.omitNonIndexed;

expression = '(?<!N)R|NR'; 
[match_o_tmp,~] = regexp({data.trials(ind).name},expression,'match','split','forceCellOutput');
match_o_tmp = reshape([match_o_tmp{:}],length(match_o_tmp{1}),length(match_o_tmp));
noReward = strcmp('NR',match_o_tmp);
Reward = strcmp(match_o_tmp,'R');

if any (~(noReward|Reward))
    warning(['Error: Could not determine trial outcome in cell ' num2str(data.info.cell_ID )])
end

match_o = nan(size(match_o_tmp,1),length(data.trials));
match_o(:,ind) = Reward;

% choice 
if size(match_o,1)==2
    choice = [data.trials.choice];
    match_o_choice = nan(1,size(match_o,2));
    for i=1:length(data.trials)
        if choice(i)
            match_o_choice(i) = match_o(1,i);
        else
            match_o_choice(i) = match_o(2,i);
        end
    end
    match_o = match_o_choice;
end

if omitNonIndexed
    match_o(setdiff(1:length(data.trials),ind)) = [];
end

