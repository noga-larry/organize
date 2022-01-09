function match_op = getPreviousOutcomes(data,ind,varargin)

if nargin==1
    ind=1:length(data.trials);
elseif nargin>2
    assert(isnumeric(ind))
end

p = inputParser;
defaultOmitNonIndexed = false;
addOptional(p,'omitNonIndexed',defaultOmitNonIndexed,@islogical);

parse(p,varargin{:})
omitNonIndexed = p.Results.omitNonIndexed;

match_o = getOutcome(data);
match_op_tmp = nan(1,length(data.trials));
for i=2:length(data.trials)
    if data.trials(i).previous_completed
        match_op_tmp(i) = match_o(i-1);
    else
        match_op_tmp(i) = nan;
    end
end

if omitNonIndexed
    match_op = match_op_tmp(ind);
    
else
    match_op = nan(1,length(data.trials));
    match_op(ind) = match_op_tmp(ind);
end
    