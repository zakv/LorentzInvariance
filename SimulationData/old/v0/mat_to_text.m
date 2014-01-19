function [ ] = mat_to_text( file_name )
%Converts .mat files into .set files, which are larger/slower but human
%readable.
%   file_name should be the name of the input file including the extension.

    [directory,bare_name,~]=fileparts(file_name);
    out_file_name=fullfile( directory, strcat(bare_name,'.set') );
    data_array=load_mat(file_name);
    write_data_set(out_file_name,data_array);
    disp( strjoin({'Created',out_file_name}) );
end

