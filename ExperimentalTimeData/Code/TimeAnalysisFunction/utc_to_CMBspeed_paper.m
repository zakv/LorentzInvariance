function [v] = utc_to_CMBspeed_paper(t)
%calculates the speed of CERN position relative to CMB frame. Referred from
%(http://arxiv.org/pdf/0912.2803v2.pdf) : there are some errors
% or
%M. E. Tobar, P. L. Stanwix, M. Susli, et al., Lect. Notes Phys: Special
%Relativity 702, 416 (2006). : this is more reliable


%for CMB velocity relative of solar system u_vec
phi_mu = -6.4*pi/180; %[rad]
%u = 377; %[km/s] earth frame CMB velocity. from TestingLocalLorentz paper
u = 3.698839346804000e+02; %from (http://iopscience.iop.org/0004-637X/707/2/916/pdf/0004-637X_707_2_916.pdf)

%for Earth orbital velocity v0_vec
v0 = 29.78; %[km/s] orbital velocity with respect to the Earth frame
Omega = 0.017203;%[rads/day] annual frequency
t0 = 7.305653159722222e+05; %[day] datenum(2000,3,20,7,35,0) J2000 equinox
lambda0 = Omega.*(t - t0)+pi; %[rad] t0: J2000 equinox (vernal) but it should be autumnal since x coordinate is alligned to autumnal equinox

%for Earth rotation velocity vR_vec( I think this is wrong; coordinate
%transformation R_alpha should be multiplied for MM-earth frame)
%LATITUDE = 46.2341*pi/180;
%LONGITUDE = 6.0462*pi/180;
%omega = 7.29*10^(-5);%[rad/s] angular frequency of the Earth rotation with respect to the stars (sidereal frequency)
%R = 6370; %[km] equatorial radius of the Earth
%Phi = LONGITUDE ; %[rad] initial londitude for CERN experiment at time t=0
%lambda = omega.*(t - t0)*60*60*24 + Phi;%[rad] longitude in the Earth frame
%chi = LATITUDE; %[rad] latitude of a place

%coordinate transformation from Barycentric frame to Geocentric frame
epsilon = 23.27 *pi/180; %[rad] angle between the equatorial and orbital plane
R_epsilon = [1 0 0; 0 cos(epsilon) -sin(epsilon); 0 sin(epsilon) cos(epsilon)];

%coordinate transformation from Geocentric frame to MM-earth frame
alpha = 167.9*pi/180; %right ascension of u_vec
R_alpha = [cos(alpha) sin(alpha) 0; -sin(alpha) cos(alpha) 0; 0 0 1];%rotational transformation


%three vectors
iMax = numel(t);
u_vec = zeros(3,numel(t));
v0_BRS_vec = zeros(3,numel(t));
v0_GRS_vec = zeros(3,numel(t));
v0_vec = zeros(3,numel(t));
%vR_vec = zeros(3,numel(t));
v_vec = zeros(3,numel(t));
v = zeros(size(t));

for i = 1:iMax
    %MM Earth frame
    u_vec(:,i) = u.*[cos(phi_mu);0;sin(phi_mu)];
    %vR_vec(:,i) = omega*R*cos(chi).*[-sin(lambda(i));cos(lambda(i));0]; 
    
    %barycentric non-rotating frame (BRS)
    v0_BRS_vec(:,i) = v0.*[-sin(lambda0(i));cos(lambda0(i));0];
    %geocentric frame (GRS)
    v0_GRS_vec(:,i) = R_epsilon*v0_BRS_vec(:,i);
    %MM Earth frame
    v0_vec(:,i) = R_alpha*v0_GRS_vec(:,i);
    
    %CMB velocity
    v_vec(:,i) = u_vec(:,i) + v0_vec(:,i);% + vR_vec(:,i);
    v(i) = dot(v_vec(:,i),v_vec(:,i))^0.5;%[km/s]
    
    %for testing
    %v(i) = v0_GRS_vec(3,i);
    
end 
%for i = 1:iMax
%    dispstr = ['Earth orbital velocity (GRS) :(',num2str(v0_GRS_vec(1,i)),',',num2str(v0_GRS_vec(2,i)),',',num2str(v0_GRS_vec(3,i)),')'];
%    disp(dispstr);
%end
    %dispstr = ['CMB velocity :(',num2str(u_GRS_vec(1,1)),',',num2str(u_GRS_vec(2,1)),',',num2str(u_GRS_vec(3,1)),')'];
    %disp(dispstr);

end