function [b_0,b_1,R_squared,nObservetions] = caliberateExtendedBehavior ...
    (maestroH,maestroV,extendedH,extendedV)

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


mdl = fitlm(extendedH,maestroH);
b_0(1) = mdl.Coefficients.Estimate(1);
b_1(1) = mdl.Coefficients.Estimate(2);
R_squared(1) = mdl.Rsquared.Ordinary;

mdl = fitlm(extendedV,maestroV);
b_0(2) = mdl.Coefficients.Estimate(1);
b_1(2) = mdl.Coefficients.Estimate(2);
R_squared(2) = mdl.Rsquared.Ordinary;

nObservetions = mdl.NumObservations; 


end

