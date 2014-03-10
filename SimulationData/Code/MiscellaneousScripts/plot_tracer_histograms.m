four_month=Analysis('FourMonth');
four_month.add_position_generator();
position_generator=four_month.position_generator_list{1};

if exist('plots','dir')~=7
    mkdir plots
end

for j=1:9
    for direction=1:2
        temp=figure('WindowStyle','Docked');
        if direction==1
            tracer_data_set=position_generator.left_data_set_list{j};
            quip_string='left';
        elseif direction==2
            tracer_data_set=position_generator.right_data_set_list{j};
            quip_string='right';
        end
        charge=tracer_data_set.charge;
        charge_string=num2str(charge);
        hist(tracer_data_set.z_positions,150);
        title_string=['fracq=',charge_string,' quip=',quip_string];
        title(title_string);
        xlim([-0.15,0.15]);
        file_name=['plots/quip_',quip_string,'_fracq_',charge_string,'.png'];
        print(temp,file_name,'-dpng')
        xlabel('z (meters)');
        ylabel('bin count');
    end
end