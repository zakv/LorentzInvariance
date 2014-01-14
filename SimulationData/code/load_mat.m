function [ data ] = load_mat( file_name )
%Wrapper function to load data from a .mat file.  Paired with save_mat
%   file_name should be the name of the output file, optionally inclduing
%   the file extension '.mat'.  Returns the data

    if ~strcmp(file_name(end-3:end),'.mat')
        file_name=strcat(file_name,'.mat');
    end
    returned_object=load(file_name,'data');
    data=returned_object.data;
end

