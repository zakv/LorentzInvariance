%this script is intended to produce the figure that demonstrates how
%z-positions are chosen from the CDF of Tracer data.

%Parameters that may be 
rand_val=0.66; %Used to pick from CDF
charge_balance=1/5.0; %Will choose a charge for interpolation this
%fraction of the way bewteen the left value to the right value

%Get the tracer data from a position_generator instance
cd ../Classes/
four_month=Analysis('FourMonth');
four_month.add_position_generator();
position_generator=four_month.position_generator_list{1};
left_data_set=position_generator.left_data_set_list{end-1};
right_data_set=position_generator.left_data_set_list{end-2};
[left_cdf,left_z_array]=ecdf(left_data_set.z_positions);
[right_cdf,right_z_array]=ecdf(right_data_set.z_positions);
left_z_array=left_z_array*1000.0; %Convert to mm
right_z_array=right_z_array*1000.0;

%Do interpolation
charge=left_data_set.charge+charge_balance*(right_data_set.charge-left_data_set.charge);
left_z_position=position_generator.interpolate_z_cdf(left_data_set,rand_val);
right_z_position=position_generator.interpolate_z_cdf(right_data_set,rand_val);
z_position=position_generator.get_one_z_position(charge,1,rand_val);
left_z_position=left_z_position*1000.0; %Convert to mm
right_z_position=right_z_position*1000.0;
z_position=z_position*1000.0;

%Create plot
fig=figure('WindowStyle','docked');
hold on
plot(left_z_array,left_cdf,'b-'); %Plot left cdf
plot(right_z_array,right_cdf,'b-'); %Plot right cdf
plot([-150,150],rand_val*[1,1],'g--') %Horizontal interpolation line
plot(left_z_position*[1,1,],[0,rand_val],'g--'); %Left vertical line
plot(left_z_position,rand_val,'go'); %Mark left intersection
plot(right_z_position*[1,1],[0,rand_val],'g--'); %Right vertical line
plot(right_z_position,rand_val,'go'); %Mark right intersection
plot(z_position*[1,1],[0,rand_val],'r-.'); %Vertical line for interpolated charge
plot(z_position,rand_val,'r*'); %Mark middle intersection
xlim([-150,150]);
ylabel('CDF');
xlabel('Axial Position z (mm)')
hold off

cd ../MiscellaneousScripts/
if exist('plots','dir')~=7
    mkdir plots
end
%Save the figure
file_name='plots/CDF_Interpolation_Plot1';
print(fig,file_name,'-depsc')

%Create Zoomed in version
x_limits=zeros(2,1); %Limits for plot's x-axis
delta_z=abs(right_z_position-left_z_position);
width_scaling=1.0;
min_z=min([left_z_position,right_z_position]);
max_z=max([left_z_position,right_z_position]);
x_limits(1)=min_z-width_scaling*delta_z;
x_limits(2)=max_z+width_scaling*delta_z;
x_limits=sortrows(x_limits);
xlim(x_limits);
ylim(rand_val+[-0.1,0.1]);
%left_label=sprintf('Q=%0.1e',left_data_set.charge);
%right_label=sprintf('Q=%0.1e',right_data_set.charge);
%legend(left_label,right_label,'Location','Northwest'); %Sort of pointless

%Save the figure
file_name='plots/CDF_Interpolation_Plot2';
print(fig,file_name,'-depsc')