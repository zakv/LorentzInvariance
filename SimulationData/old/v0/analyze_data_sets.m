function [ all_params ] = analyze_data_sets( file_name_list )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    %Need analysis functions
    addpath ../../CharmanUltra/
    
    %Get pool ready if necessary
    close_pool_when_done=false;
    if matlabpool('size')==0
        matlabpool('open')
        close_pool_when_done=true;
    end    
    
    all_params=get_all_params(file_name_list); %Run calculations on data
    
    
    
    %Close pool is necessary
    if close_pool_when_done==true
        matlabpool('close')
    end
end