function  events  = targetMovementOnOffSet( targets )
    % This function finds the begining an end of the target movement
    
MOVMENT_TIME = 30; 
temp = sum(abs(targets.hvel) + abs(targets.vvel));
count = 1;
for i = 1:length(temp)
    if temp(i)>0
        count = count + 1;
    else
        count = 0;
    end
    
    if count > MOVMENT_TIME
     events.movement_onset = i - MOVMENT_TIME;
     events.movement_offset = find(temp(events.movement_onset:length(temp))== 0, 1) +events.movement_onset - 1 ;
     break
    end
end

    
%     [~,move_v_ind] = find(targets.vvel); 
%     [~,move_h_ind] = find(targets.hvel); 
%     
%     move_v_diff = diff(move_v_ind,2);
%     move_h_diff = diff(move_h_ind,2);
%     
%     
%     
%     onset = min (union(move_v,move_h));
%     offset = max (union(move_v,move_h)); 
%     
%     events.movement_onset = onset;
%     events.movement_offset = offset;

end

