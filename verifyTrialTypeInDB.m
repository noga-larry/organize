function [boolVerifieid] = verifyTrialTypeInDB(dataSet,MaestroTrialName,DBTask)

% This function is designed to determine the MaestroTask (a trial type) 
% based on the given inputs, specifically dataSet, MaestroTrialName, 
% and DBTask. This is used to seperate sessions and needs to be extended to
% include additional tasks in additional datasets. 

switch dataSet
    
    case {'Vermis','Golda'}
        if ~isempty(regexp(MaestroTrialName,'vs'))
           MaestroTask = 'choice';
        elseif isempty(regexp(MaestroTrialName,'v'))
           MaestroTask = 'saccade_8_dir_75and25';
        else
            vel = regexp(MaestroTrialName,'(?<=v)[0-9]*','match');
            vel = str2num(vel{1});
            if vel==20
              MaestroTask = 'pursuit_8_dir_75and25';
            elseif vel==15 || vel==25
                MaestroTask = 'speed_2_dir_0,50,100';
            end
        end
         
    otherwise 
           MaestroTask = DBTask;
end

boolVerifieid = strcmp(MaestroTask,DBTask);