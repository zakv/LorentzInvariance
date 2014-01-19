function [ ] = save_mat( file_name, data_array )
%Wrapper function to save one array to a .mat file.  Paired with load_mat
%   file_name should be the name of the output file, optionally inclduing
%   the file extension '.mat'.

    if ~strcmp(file_name(end-3:end),'.mat')
        file_name=strcat(file_name,'.mat');
    end
    save(file_name,'data_array');
end

