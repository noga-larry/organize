function  [onset offset]  = targetMovementOnOffSet( targets, trialType )
% This function finds the beginning and end of the target movement

if ~(exist('trialType','var') == 1)
   trialType = 'pursuit'
end
    

switch trialType
   case 'pursuit'
      MOVMENT_TIME = 30; 
   case 'saccade'
      MOVMENT_TIME = 1; 
end    
    
temp = sum(abs(targets.hvel) + abs(targets.vvel),1);
count = 1;
for i = 1:length(temp)
    if temp(i)>0
        count = count + 1;
    else
        count = 0;
    end
    
    if count > MOVMENT_TIME
     onset = i - MOVMENT_TIME;
     offset = find(temp(onset:length(temp))== 0, 1) + onset - 1 ;
     break
    end
end



end

