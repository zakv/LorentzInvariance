function [] = ellip_to_mat(file_name)
%Converts the given file_name into a sorted .mat file
%   file_name should be relative to the TracerOutput directory.
    file_name=fullfile('../../TracerOutput/',file_name);
    [directory,bare_name,~]=fileparts(file_name);
    out_file_name=fullfile( directory, strcat(bare_name,'.mat') );
    t_z_array=dlmread(file_name);
    data_array=t_z_array(:,2);
    data_array=sortrows(data_array);
    save_mat(out_file_name,data_array);
    disp( strjoin({'Created',out_file_name}) );
end