function [ smoothed_vec ] = gaussSmooth(vec, SD)
% Gassian smoothing of an array (vec) with standard deviation (SD)

 win = normpdf(-3*SD:3*SD,0,SD);
 win = win/sum(win);
 smoothed_vec = filtfilt(win,1,vec);

end

