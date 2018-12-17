function [adresses] = getAdress(reqParams,dir_from)
% Ths function finds paths to relevent cells data structure, using the
% task_DB data base. The function looks for cell that satisty some demands.
% Inputs:   reqParams    A data structure with the different damands from
%                        the requested cells. 
%             .cell_type   The cell type of the requested cell, the
%                          function looks for cell with reqParams.cell_type
%                          in their cell_type discription.
%             .num_trials  Minimal number of trials per cell.
%             .grade       Maximal grade. 

load ([dir_from '\task_DB'])

boolType = ~cellfun(@isempty,regexp({task_DB.cell_type},reqParams.cell_type));
boolNumTrials = [task_DB.num_trials]>=reqParams.num_trials;
boolgrade = [task_DB.grade]<=reqParams.grade;

ind = find(boolType.*boolNumTrials.*boolgrade);
adresses = strcat([dir_from '\'],{task_DB(ind).name});



