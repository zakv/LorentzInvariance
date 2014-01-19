function [ ] = save_mat( file_name, data ) %#ok<INUSD>
%Wrapper function to save data to a .mat file.  Paired with load_mat
%   file_name should be the name of the output file, optionally inclduing
%   the file extension '.mat'.

    if length(file_name)<4 || ~strcmp(file_name(end-3:end),'.mat')
        file_name=strcat(file_name,'.mat');
    end
    save(file_name,'data');
end

