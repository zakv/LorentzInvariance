function [ ] = text_to_mat( file_name )
%Converts .ellip  and .set files into .mat files for compression/fast access
%   file_name should be the name of the input file, including the extension

    [directory,bare_name,~]=fileparts(file_name);
    out_file_name=fullfile( directory, strcat(bare_name,'.mat') );
    data_array=read_data_set(file_name);
    save_mat(out_file_name,data_array);
    disp( strjoin({'Created',out_file_name}) );
end

