function data = addPreviousTrial (data)
% This function adds a fields to the strcture data, 'previous_outcome' that
% is 0 is there was no reward in the previous trial of the same kind and 1
% if there was. In a two target choice task the previous trial of the same
% kind is a trial where the same target had been chosen.

[probabilities,match_p] = getProbabilities (data);

previous_outcome = containers.Map(probabilities,nan(length(probabilities),1));
for ii=1:length(data.trials)
    if data.trials(ii).choice==1
        
        chosen_target = match_p{1,ii};
    else
        chosen_target = match_p{2,ii};
    end
    data.trials(ii).previous_outcome = previous_outcome(chosen_target);
    % update
    if ~data.trials(ii).fail
        C = strsplit(data.trials(ii).name,'vs');
        if data.trials(ii).choice==1
            
            previous_outcome(chosen_target)=...
            cellfun('isempty',regexp(C(1),'NR'));
        else
             previous_outcome(chosen_target)=...
            cellfun('isempty',regexp(C(2),'NR'));
        end
       
    end
end

end








