function [ data_array ] = load_mat( file_name )
%Wrapper function to load an array from a .mat file.  Paired with save_mat
%   file_name should be the name of the output file, optionally inclduing
%   the file extension '.mat'.  Returns the array

    if ~strcmp(file_name(end-3:end),'.mat')
        file_name=strcat(file_name,'.mat');
    end
    returned_object=load(file_name,'data_array');
    data_array=returned_object.data_array;
end

