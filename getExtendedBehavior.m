function [data] = getExtendedBehavior (data,supPath,MaestroPath)

BLINK_THRESHOLD = 25; % deg
BLINK_MARGIN = 100; % ms
MOTION_DURATION = 750;

b_0 = data.extended_caliberation.b_0;
b_1 = data.extended_caliberation.b_1;

data = getBehavior (data,supPath);

for t=1:length(data.trials)
    
    extended = importdata (  [MaestroPath '\' data.info.monkey '\' data.info.session ...
        '\extend_trial\' data.trials(t).maestro_name '.mat']);
    data.trials(t).extended_hPos = b_0(1)+b_1(1)*extended.eyeh';
    data.trials(t).extended_vPos = b_0(2)+b_1(2)*extended.eyev';
    data.trials(t).extended_hVel = diff(gaussSmooth(data.trials(t).extended_hPos,10))*1000;
    data.trials(t).extended_vVel = diff(gaussSmooth(data.trials(t).extended_vPos,10))*1000;
    data.trials(t).extended_trial_begin = extended.trial_begin_ms;
    
    
    ind  = find(abs(data.trials(t).extended_hPos)>BLINK_THRESHOLD |...
        abs(data.trials(t).extended_vPos)>BLINK_THRESHOLD);
    blinkBegin = [];
    blinkEnd = [];
    if ~isempty(ind)
        changes = find(diff([-70 ind])>1);
        blinkBegin = ind(changes);
        blinkEnd = [ind(changes(2:end)), ind(length(ind))];
        blinkBegin = max(blinkBegin-BLINK_MARGIN,1);
        blinkEnd = min(blinkEnd+BLINK_MARGIN, length(data.trials(t).extended_vPos));
    end
    data.trials(t).extended_blink_begin = blinkBegin;
    data.trials(t).extended_blink_end = blinkEnd;
    
    blinks = sort ([blinkBegin,blinkEnd]);
    targetOffset = data.trials(t).movement_onset +MOTION_DURATION;
    [beginSaccade, endSaccade] = ...
        getSaccades(data.trials(t).extended_hVel,...
        data.trials(t).extended_vVel, blinks, data.trials(t).movement_onset, targetOffset);
    
    data.trials(t).extended_saccade_begin = beginSaccade;
    data.trials(t).extended_saccade_end = endSaccade;
    
%     ts = data.trials(t).extended_trial_begin:(data.trials(t).rwd_time_in_extended-1);
%     
%     subplot(1,2,1)
%     plot(data.trials(t).extended_hPos,'b'); hold on
%     plot(ts,data.trials(t).hPos,'r');
%     plot(beginSaccade,data.trials(t).extended_hPos(beginSaccade),'o')
%     plot(endSaccade,data.trials(t).extended_hPos(endSaccade),'o'); 
%     
%     plot(blinkBegin,data.trials(t).extended_hPos(blinkBegin),'*')
%     plot(blinkEnd,data.trials(t).extended_hPos(blinkEnd),'*'); hold off
%     
%     
%     
%     subplot(1,2,2)
%     plot(data.trials(t).extended_vPos,'b'); hold on
%     plot(ts,data.trials(t).vPos,'r');
%     plot(beginSaccade,data.trials(t).extended_vPos(beginSaccade),'o')
%     plot(endSaccade,data.trials(t).extended_vPos(endSaccade),'o');
%     
%     
%     plot(blinkBegin,data.trials(t).extended_vPos(blinkBegin),'*')
%     plot(blinkEnd,data.trials(t).extended_vPos(blinkEnd),'*'); hold off
    
end

