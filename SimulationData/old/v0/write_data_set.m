function [ ] = write_data_set( file_name, t_z_array )
%Writes t_z_array to a file
%   Times should be recorded in datenum() format and annihilation
%   z-positions should be recorded as meters from trap center.  The
%   extension '.set' will be appended to file_name if the name does not
%   already end with '.set'.
    OUTPUT_FILE_EXTENSION='.set';
    if ~strcmp(file_name(end-3:end),OUTPUT_FILE_EXTENSION)
        file_name=strcat(file_name,OUTPUT_FILE_EXTENSION);
    end
    dlmwrite(file_name,t_z_array,'delimiter',' ','precision',16);
end