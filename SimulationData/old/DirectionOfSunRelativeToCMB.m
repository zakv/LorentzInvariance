function [] = DirectionOfSunRelativeToCMB()
%To run, execute DirectionOfSunRelativeToCMB()
%   This function takes literature values for the direction of the velocity
%   of the Sun with respect to the cosmic microwave background and compares
%   them.  The 2009 reference uses an Equitorial coord system.  The 2013
%   reference uses a Galactic coord system. A transformation is carried out
%   here so that the directions can be compared.

degree = pi/180; % radians
hour = pi/12; % radians

% Equatorial coordinates (J2000.0) of galactic reference points	
%[ http://en.wikipedia.org/wiki/Galactic_coordinate_system ]
% Galactic North Pole (z^hat_G)
%GNP = LatLongToRect(27.13*degree, (12+51.4/60)*hour);
% Galactic Center (x^hat_G)
%GC = LatLongToRect(-28.94*degree, (17+45.6/60)*hour);


%Equatorial coordinates (J2000.0) of galactic reference points 
%[ http://heasarc.gsfc.nasa.gov/cgi-bin/Tools/convcoord/convcoord.pl ]
% Galactic North Pole (z^hat_G)
GNP = LatLongToRect(27.128251*degree, 192.859481*degree);
% Galactic Center (x^hat_G)
GC = LatLongToRect(-28.936172*degree, 266.404996*degree);

% Galactic y-direction unit vector (y^hat_G)
yG = cross(GNP, GC);

% Rotation matrix [element of SO(3)] that maps Equitorial unit vectors into
%Galactic unit vectors
R = [GC; yG; GNP]';

% From 2009 archive paper [ http://arxiv.org/pdf/0912.2803v2.pdf ] (angles 
%relative to Equitorial coord system)
u1 = LatLongToRect(-6.4*degree, 11.2*hour)';

% From Planck 2013 paper [ http://arxiv.org/pdf/1303.5087v1.pdf ] (angles
%relative to Galactic coord system)
u2 = LatLongToRect(48.26*degree, 264*degree)';
converted_u2=R*u2;

%Planck 2013 data converted using NASA's online converter directly
NASA_u2=transpose(LatLongToRect(-6.930604*degree,167.934244*degree));

disp('Direction of the velocity of the Sun with respect to the cosmic microwave background:');
disp('Result from 2009 paper (Equitorial coord system)');
disp(u1);
disp('Result from 2013 paper (mapped back to Equitorial coord system using transformation matrix)');
disp(converted_u2);
disp('Result from 2013 paper converted using NASA''s online converter')
disp(NASA_u2);
disp('Angle between 2009 and 2013 vectors (degrees)');
disp(acos(u1'*NASA_u2)/degree);
end

% Return unit vector, given the usual spherical coordinates
function retval = unit(th, ph)
    retval = [sin(th)*cos(ph) sin(th)*sin(ph) cos(th)];
end

% Return unit vector, given latitude and longitude
function retval = LatLongToRect(lat, long)
    retval = unit(pi/2-lat, long);
end