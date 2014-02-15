function [f] = utc_to_lorentz_factor(t)
%calculate gamma, Lorentz factor

c = 299792.458; %[km/s]
bSq = (utc_to_CMBspeed_eq(t)./c).^2;

f = 1./sqrt(1 - bSq);

