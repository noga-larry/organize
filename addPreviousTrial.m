function data = addPreviousTrial (data)
% This function adds a fields to the strcture data, 'previous_outcome' that
% is 0 is there was no reward in the previous trial of the same kind and 1
% if there was. In a two target choice task the previous trial of the same
% kind is a trial where the same target had been chosen. 

[probabilities,match_p] = getProbabilities (data);

previous_outcome = containers.Map(probabilities,nan(length(probabilities),1));
for ii=1:length(data.trials)
    data.trials(ii).previous_outcome = previous_outcome(match_p{ii});
    % update
    if ~data.trials(ii).fail
        previous_outcome(match_p{ii})=...
            cellfun('isempty',regexp({data.trials(ii).name},'NR'));
    end
end

end








