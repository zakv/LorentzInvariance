%Automatically converts all the .ellip data files in TracerData to .mat
%files
tracer_output_dir='../../TracerOutput/';
search_string=fullfile(tracer_output_dir,'SimData_*.ellip');
file_list=dir(search_string);
%file_name_list=fullfile(tracer_output_dir,{file_list.name});
file_name_list={file_list.name};
jMax=length(file_name_list);
for j=1:jMax
    file_name=file_name_list{j};
    fprintf('Converting %s\n',file_name);
    ellip_to_mat(file_name);
end