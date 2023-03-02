function [data, extended_behavior_fit] = caliberateExtendedBehavior ...
    (data,dataPath,MaestroPath)

% This function fits models between the behavioe measured in the extended
% data and in Maestro, in order to find caliberation values.
% Inputs:
%               maestroH  Concatinated horizontal behavior values from
%               Maestro.
%               maestroV  Concatinated Vertical behavior values from
%               Maestro.
%               extendedH Concatinated horizontal behavior values from
%               the extended data.
%               maestroV  Concatinated Vertical behavior values from
%                         the extended data.
% Important Note: blinks must be replaced with nans in all inputs!
% Outputs:      b_0       Intercept values b_0(1) - horizontal; b_0(2) -
%                         vertical
%               b_1       Slop values b_1(1) - horizontal; b_1(2) -
%                         vertical
%               R_squared R_squared values R_squared (1) - horizontal;
%                         R_squared (2) - vertical
%               nObservetions
%                         Number od observation used to fit the models.

WARNING_R_SQ = 0.97;
data = getBehavior (data,dataPath);
WARNING_NUM_OBSV =30000;

for  i =1:length(data.trials)

    extended = importdata([MaestroPath  '\'  data.info.monkey '\' data.info.session '\extend_trial\' ...
        data.trials(i).maestro_name '.mat']);


    [exHraw,exVraw,maeHraw,maeVraw] = ...
        prepareVarsForExtendedBehaviorCalb(extended,data.trials(i));

    extendedH{i} = exHraw';
    extendedV{i} = exVraw';
    maestroH{i} = maeHraw;
    maestroV{i} = maeVraw;

end

[b_0,b_1,R_squared,nObservetions] = ...
    fitCalbModel([extendedH{:}],[maestroH{:}],[extendedV{:}],[maestroV{:}]);

extended_behavior_fit = any(R_squared<WARNING_R_SQ)...
    | nObservetions < WARNING_NUM_OBSV;

if extended_behavior_fit
    warning(['Problem with extended behavior caliberation in cell %s: '...
        'R_squared = %d, %f.; nObservetions = %g'],num2str(data.info.cell_ID)...
        ,R_squared(1),R_squared(2),nObservetions)
end

data.extended_caliberation.nt = nObservetions;
data.extended_caliberation.b_0 = b_0;
data.extended_caliberation.b_1 = b_1;
data.extended_caliberation.R_squared = R_squared;
data.extended_caliberation.extended_behavior_fit = extended_behavior_fit;
end


function [b_0,b_1,R_squared,nObservetions] = ...
    fitCalbModel(extendedH,maestroH,extendedV,maestroV)
mdlH = fitlm(extendedH,maestroH);
b_0(1) = mdlH.Coefficients.Estimate(1);
b_1(1) = mdlH.Coefficients.Estimate(2);
R_squared(1) = mdlH.Rsquared.Ordinary;

mdlV = fitlm(extendedV,maestroV);
b_0(2) = mdlV.Coefficients.Estimate(1);
b_1(2) = mdlV.Coefficients.Estimate(2);
R_squared(2) = mdlV.Rsquared.Ordinary;

nObservetions = mdlV.NumObservations;

end

function [exHraw,exVraw,maeHraw,maeVraw ] = ...
    prepareVarsForExtendedBehaviorCalb(extended,trialData)

BLINK_MARGIN = 100; %ms
REMOVE_EDGE = 15; %ms
% values for extended data caliberation

exHraw = extended.eyeh(extended.trial_begin_ms:(extended.trial_end_ms-1));
exVraw = extended.eyev(extended.trial_begin_ms:(extended.trial_end_ms-1));
maeHraw = trialData.hPos;
maeVraw = trialData.vPos;

assert(length(exHraw)==length(trialData.hPos))

nanBegin = max(trialData.blinkBegin-BLINK_MARGIN,1);
nanEnd = min(trialData.blinkEnd+BLINK_MARGIN,length(maeVraw));

exHraw = removesSaccades(exHraw,nanBegin,nanEnd);
exVraw = removesSaccades(exVraw,nanBegin,nanEnd);
maeHraw = removesSaccades(maeHraw,nanBegin,nanEnd);
maeVraw = removesSaccades(maeVraw,nanBegin,nanEnd);

exHraw = exHraw(REMOVE_EDGE:end-REMOVE_EDGE);
exVraw = exVraw(REMOVE_EDGE:end-REMOVE_EDGE);
maeHraw = maeHraw(REMOVE_EDGE:end-REMOVE_EDGE);
maeVraw = maeVraw(REMOVE_EDGE:end-REMOVE_EDGE);


end
