function [ smoothed_vec ] = gaussSmooth(vec, SD)
% Gassian smoothing of an array (vec) with standard deviation (SD)

 win = normpdf(-3*SD:3*SD,0,SD);
 win = win/sum(win);
 smoothed_vec = filtfilt(win,1,vec);
 % 
%  inf_val = 10^100;
%  inf_vec = vec;
%  inf_vec(isnan(inf_vec)) = inf_val;

 
%   inf_smooth = filtfilt(win,1,inf_vec);
%   figure; plot(inf_smooth); 
end

