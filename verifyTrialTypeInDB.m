function [boolVerifieid] = verifyTrialTypeInDB(dataSet,MaestroTrialName,DBTask)

switch dataSet
    
    case 'Vermis'
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
         
end

boolVerifieid = strcmp(MaestroTask,DBTask);