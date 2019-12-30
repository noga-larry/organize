function [coefH,coefV,R_squared,nt] = caliberateExtendedBehavior (maestroH,maestroV,extendedH,extendedV);

data = getBehavior (data,maestroPath);
maestroH = [data.trials.hPos];
maestroV = [data.trials.vPos];

extendedH = [];
extendedV = [];

for t =1:length(data.trials)
extended = importdata (  [maestroPath '\'  data.info.session ...
   '\extend_trial\' data.trials(t).maestro_name '.mat']);


data.trials(t).extended_hPos = extended.eyeh;
data.trials(t).extended_vPos = extended.eyev;

extendedH = [extendedH; extended.eyeh(extended.trial_begin_ms:(extended.trial_end_ms-1))];
extendedV = [extendedV; extended.eyev(extended.trial_begin_ms:(extended.trial_end_ms-1))];

end

mdlH = fitlm(extendedH,maestroH);
a = mdlH.Coefficients.Estimate(1);
b = mdlH.Coefficients.Estimate(2);
extendedH = extendedH*b+a;

mdlH = fitlm(extendedV,maestroV);
a = mdlH.Coefficients.Estimate(1);
b = mdlH.Coefficients.Estimate(2);
extendedV = extendedV*b+a;

extendedH(extendedH>20) = NaN; extendedH(extendedH<-20) = NaN;
extendedV(extendedV>20) = NaN; extendedV(extendedV<-20) = NaN;

maestroH(maestroH>20) = NaN; maestroH(maestroH<-20) = NaN;
maestroV(maestroV>20) = NaN; maestroV(maestroV<-20) = NaN;

mdlH = fitlm(extendedH,maestroH);
a = mdlH.Coefficients.Estimate(1);
b = mdlH.Coefficients.Estimate(2);

mdlH = fitlm(extendedH,maestroH);
a = mdlH.Coefficients.Estimate(1);
b = mdlH.Coefficients.Estimate(2);
