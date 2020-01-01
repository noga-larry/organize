function [data] = getExtendedBehavior (data,maestroPath)

blink_threshold = 25; %deg/s

b_0 = data.extended_caliberation.b_0;
b_1 = data.extended_caliberation.b_1;

% data = getBehavior (data,maestroPath);


for t=1:length(data.trials)
    extended = importdata (  [maestroPath '\'  data.info.session ...
        '\extend_trial\' data.trials(t).maestro_name '.mat']);
    data.trials(t).extended_hPos = b_0(1)+b_1(1)*extended.eyeh';
    data.trials(t).extended_vPos = b_0(2)+b_1(2)*extended.eyev';
    data.trials(t).extended_hVel = diff(gaussSmooth(data.trials(t).extended_hPos,10))*1000;
    data.trials(t).extended_vVel = diff(gaussSmooth(data.trials(t).extended_vPos,10))*1000;
    data.trials(t).extended_trial_begin = extended.trial_begin_ms;
    
    
    ind  = find(abs(data.trials(t).extended_hPos)>blink_threshold |...
        abs(data.trials(t).extended_vPos)>blink_threshold);
    blinkBegin = [];
    blinkEnd = [];
    if ~isempty(ind)
        changes = find(diff([-70 ind])>1);
        blinkBegin = ind(changes);
        blinkEnd = [ind(changes(2:end)), ind(length(ind))];
    end
    data.trials(t).extended_blink_begin = blinkBegin;
    data.trials(t).extended_blink_end = blinkEnd;


    
    
    
    
    ts = data.trials(t).extended_trial_begin:(data.trials(t).rwd_time_in_extended-1);
    
    subplot(1,2,1)
    plot(data.trials(t).extended_hPos,'b'); hold on
    plot(ts,data.trials(t).hPos,'r');
    plot(blinkBegin,data.trials(t).extended_hPos(blinkBegin),'o')
    plot(blinkEnd,data.trials(t).extended_hPos(blinkEnd),'o'); hold off
    
    
    subplot(1,2,2)
    plot(data.trials(t).extended_vPos,'b'); hold on
    plot(ts,data.trials(t).vPos,'r');
    plot(blinkBegin,data.trials(t).extended_vPos(blinkBegin),'o')
    plot(blinkEnd,data.trials(t).extended_vPos(blinkEnd),'o'); hold off
    
    
end

