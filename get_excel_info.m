function get_excel_info(excel_file_adress, dir_to)

% This function reads the sessios exel database and creates a matlab 
% structure with the cells info using the first row as fields name. It then
% saves the matla structure. 
%Inputs:     excel_file_adress   location of the file
%            dir_to              where to save the data strcture

[~,txt,raw] = xlsread(excel_file_adress);

for ii=1:size(raw,2)
    varName = txt{1,ii};
    %get feild name
    varData = raw (2:end,ii); 
    [task_info(1:length(varData)).(varName)]=deal(varData{:});
end

nanInd = find(isnan([task_info.cell_ID]));
task_info(nanInd)=[];
save([dir_to '\task_info'],'task_info')
end

