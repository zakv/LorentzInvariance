function all_params = get_all_params( file_name_list )
%Massive iteration that applies all fit algorithms to all parameters of
%interest for both wait times and z-positions for each data set.

    %Run only on a portion of the data sets if testing
    TEST_RUN=false;
    
    %Functions that calculate parameters of interest
    param_func_list={@(date_times)get_speed(date_times),'Speed' ...
                     };
    
    %Functions that calculate fit parameters with the different algorithms
    fit_func_list={@(data)CharmanII(data,'day'), 'CharmanII Day';  ...
                   @(data)CharmanII(data,'year'), 'CharmanII Year'; ...
                   @(data)CharmanIV(data,'day'), 'CharmanIV Day';  ...
                   @(data)CharmanIV(data,'year'), 'CharmanIV Year'; ...
                   };
     
    %Do iteration
    if TEST_RUN
        jMax_file=min(100,numel(file_name_list));
    else
        jMax_file=numel(file_name_list); 
    end
    jMax_data=2; %either wait times or z-positions
    jMax_param=size(param_func_list,1);
    jMax_fit=size(fit_func_list,1);
    all_params=cell(jMax_file,jMax_param,jMax_data,jMax_fit);
    disp('Beginning iteration');
    tic
    parfor j1=1:jMax_file %iterate over files
        file_name=file_name_list{j1};
        %Read in data from file
        data_set=load_mat(file_name);
        data_list={data_set(1:end,2), 'Wait Time';...
                   data_set(1:end,3), 'z-position'...
                   };
        date_times=data_set(1:end,1);
        for j2=1:jMax_param %iterate over fit parameter algorithms
            param_func=param_func_list{j2,1};   
            param=param_func(date_times);
            for j3=1:jMax_data %do for both wait times and z-positions
                data=data_list{j3,1};
                for j4=1:jMax_fit %iterate over fitting functions
                    fit_func=fit_func_list{j4,1}; %#ok<*PFBNS>
                    all_params{j1,j2,j3,j4}=fit_func([data,param]);
                end
            end
        end
    end
    disp('Ending iteration')
    toc
end


function speed = get_speed(date_times)
%Returns an array of CMB speeds at the given times (m/s)

    [v_x,v_y,v_z]=datenum_to_cmb_velocity(date_times);
    speed=sqrt(v_x.*v_x+v_y.*v_y+v_z.*v_z);
end