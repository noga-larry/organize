function [extendedBehaviorData] = getExtendedBehaviorShadowFile(data,MaestroPath)

SD = 10; %ms
BLINK_THRESHOLD = 25; % deg
BLINK_MARGIN = 100; % ms

extendedBehaviorData.info = data.info;

b_0 = data.extended_caliberation.b_0;
b_1 = data.extended_caliberation.b_1;
for t=1:length(data.trials)
    
    extended = importdata([MaestroPath  '\'  data.info.monkey '\' ...
        data.info.session '\extend_trial\' ...
        data.trials(t).maestro_name '.mat']);
    
    extendedBehaviorData.trials(t).maestro_name = data.trials(t).maestro_name;
    extendedBehaviorData.trials(t).hPos = b_0(1)+b_1(1)*extended.eyeh';
    extendedBehaviorData.trials(t).vPos = b_0(2)+b_1(2)*extended.eyev';
    extendedBehaviorData.trials(t).hVel = ...
        diff(gaussSmooth(extendedBehaviorData.trials(t).hPos,SD))*1000;
    extendedBehaviorData.trials(t).vVel = ...
        diff(gaussSmooth(extendedBehaviorData.trials(t).vPos,SD))*1000;
    extendedBehaviorData.trials(t).extended_trial_begin = extended.trial_begin_ms;
    
    
    posTrace  = abs(extendedBehaviorData.trials(t).hPos)>BLINK_THRESHOLD |...
        abs(extendedBehaviorData.trials(t).vPos)>BLINK_THRESHOLD;
    blinkBegin = find(diff([0 posTrace])==1);
    blinkEnd= find(diff([posTrace 0])==-1);
    blinkBegin = max(blinkBegin-BLINK_MARGIN,1);
    blinkEnd = min(blinkEnd+BLINK_MARGIN, length(extendedBehaviorData.trials(t).hPos)-1);
    
    assert(length(blinkBegin)==length(blinkEnd))
    
    extendedBehaviorData.trials(t).extended_blink_begin = blinkBegin;
    extendedBehaviorData.trials(t).extended_blink_end = blinkEnd;
    
    blinks = sort ([blinkBegin,blinkEnd]);
    [beginSaccade, endSaccade] = ...
        getSaccades(extendedBehaviorData.trials(t).hVel,...
        extendedBehaviorData.trials(t).vVel, blinks,...
        extendedBehaviorData.trials(t).extended_trial_begin + data.trials(t).movement_onset...
        ,extendedBehaviorData.trials(t).extended_trial_begin + data.trials(t).movement_offset);
    
    extendedBehaviorData.trials(t).extended_saccade_begin = beginSaccade;
    extendedBehaviorData.trials(t).extended_saccade_end = endSaccade;
    
    extendedBehaviorData.trials(t).extended_saccade_begin = beginSaccade;
    extendedBehaviorData.trials(t).extended_saccade_end = endSaccade;
    

%     if any(beginSaccade>data.trials(t).rwd_time_in_extended & ...
%             beginSaccade< (data.trials(t).rwd_time_in_extended+400))...
%             || any(blinkBegin>data.trials(t).rwd_time_in_extended& ...
%             blinkBegin< (data.trials(t).rwd_time_in_extended+400))
%         continue
%     end
%     ts = extendedBehaviorData.trials(t).extended_trial_begin...
%         :(data.trials(t).rwd_time_in_extended-1);
%     
%     data = getBehavior(data,'D:\Vermis Data')
%     subplot(1,2,1)
%     plot(extendedBehaviorData.trials(t).hVel,'k'); hold on
%     plot(ts,data.trials(t).hVel,'b');
%     plot(beginSaccade,extendedBehaviorData.trials(t).hVel(beginSaccade),'or')
%     plot(endSaccade,extendedBehaviorData.trials(t).hVel(endSaccade),'om');
%     
%     plot(blinkBegin,extendedBehaviorData.trials(t).hVel(blinkBegin),'*r')
%     plot(blinkEnd,extendedBehaviorData.trials(t).hVel(blinkEnd),'*m'); hold off
%     
%     xline(data.trials(t).rwd_time_in_extended)
%     xline(data.trials(t).rwd_time_in_extended +400)
%     
%     subplot(1,2,2)
%     plot(extendedBehaviorData.trials(t).vVel,'k'); hold on
%     plot(ts,data.trials(t).vVel,'b');
%     plot(beginSaccade,extendedBehaviorData.trials(t).vVel(beginSaccade),'or')
%     plot(endSaccade,extendedBehaviorData.trials(t).vVel(endSaccade),'om');
%     
%     
%     plot(blinkBegin,extendedBehaviorData.trials(t).vVel(blinkBegin),'*r')
%     plot(blinkEnd,extendedBehaviorData.trials(t).vVel(blinkEnd),'*m'); hold off
%     
%     xline(data.trials(t).rwd_time_in_extended)
%     xline(data.trials(t).rwd_time_in_extended +400)
%     
end