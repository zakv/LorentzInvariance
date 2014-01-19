function [ output ] = analyze_data_sets_1( file_name_list )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %Run only portions of data sets 
    TEST_RUN=false;
    N_WORKERS=7;
    
    %Need analysis functions
    addpath ../../CharmanUltra/
    
    %Get pool ready if necessary
    close_pool_when_done=0;
    if matlabpool('size')==0
        matlabpool('open')
        close_pool_when_done=1;
    end    
    
    %Calculate parameters of interest
    param_func_list={@(date_times)get_speed(date_times),'Speed' ...
                     };
    
    %Calculate fit parameters with the different algorithms for both
    %z-positions and wait times.
    fit_func_list={@(data)CharmanII(data,'day'), 'CharmanII Day';  ...
                   @(data)CharmanII(data,'year'), 'CharmanII Year'; ...
                   @(data)CharmanIV(data,'day'), 'CharmanIV Day';  ...
                   @(data)CharmanIV(data,'year'), 'CharmanIV Year'; ...
                   };
     
    %Do iteration
    if TEST_RUN
        jMax_file=min(15,numel(file_name_list));
    else
        jMax_file=numel(file_name_list); 
    end
    jMax_data=2;
    jMax_param=size(param_func_list,1);
    jMax_fit=size(fit_func_list,1);
    disp('Beginning iteration');
    tic
    
    file_batch=cell(1,N_WORKERS);
    batch_size=floor(jMax_file/N_WORKERS);
    for j=1:(N_WORKERS-1)
        file_batch{j}=file_name_list(( (j-1)*batch_size+1 ):(j*batch_size));
    end
    file_batch{N_WORKERS}=file_name_list( (j*batch_size+1):end );
    
    output=cell(N_WORKERS,batch_size,jMax_param,jMax_data,jMax_fit);
    
    parfor j0=1:N_WORKERS %iterate over files
        iteration_batch=file_batch{j0};
        for k=1:batch_size
            %j1=(j0-1)*batch_size+k;
            file_name=iteration_batch{k};
            %Read in data from file
            data_set=load_mat(file_name);
            data_list={data_set(1:end,2), ...
                       data_set(1:end,3) ...
                       };
            date_times=data_set(1:end,1);
            for j2=1:jMax_param  
                param_func=param_func_list{j2};   
                param=param_func(date_times);
                for j3=1:jMax_data %iterate over parameters of interest
                    data=data_list{j3};
                    for j4=1:jMax_fit %iterate over fitting functions
                        fit_func=fit_func_list{j4}; %#ok<*PFBNS>
                        output{j0,k,j2,j3,j4}=fit_func([data,param]);
                    end
                end
            end
        end
    end
    disp('Ending iteration')
    toc
    
    %Close pool is necessary
    if close_pool_when_done==1
        matlabpool('close')
    end
end

function speed = get_speed(date_times)
%Returns an array of CMB speeds at the given times (m/s)

    [v_x,v_y,v_z]=datenum_to_cmb_velocity(date_times);
    speed=sqrt(v_x.*v_x+v_y.*v_y+v_z.*v_z);
end

