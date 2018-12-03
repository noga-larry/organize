clear
session = 'al180905';
new_base = 'al180905a.';
base_name = 'C:\noga\Albert behavior\Maestro Data\al180905';
old_dir = cd('C:\noga\Albert behavior\Maestro Data\al180905');
files = dir(base_name); files = files(3:end);
%first = 1;
first =1;
last = length(files);
%last = 80;
 
for i=first:last
    new_name = [new_base files(i).name(end-3:end)];
    %   new_name = [new_base sprintf('%04d', i+88)];
    %     new_val =  str2num(new_name(end-2))-1;
    %     new_name(end-2) = num2str(new_val);
    %     new_name(end-3) = '1';
    if(strcmp(files(i).name, new_name))
        continue;
    end
    A = java.io.File(files(i).name);
    A.renameTo(java.io.File(new_name));
    
    %java.io.File(files(i).name).renameTo(java.io.File(new_name));        
    %    movefile(files(i).name, new_name);
%    old_file = files(i).name;
    
%     str = ['mv ' sprintf('%s', old_file) ' ' sprintf('%s', new_name)]; 
%     system(str);
%    eval(str);
%     !mv `old_file` `new_name`
end
cd(old_dir);
 
 

