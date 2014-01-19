function speed = param_speed(data_set,direction)
%Returns an array of CMB speeds at the given times (m/s)
%   If direction==1, it operates on the quip left data.  If direction==2,
%   it operates on the quip right data.

[v_x,v_y,v_z]=data_set.calc_data_set.get_velocity(direction);
speed=sqrt(v_x.*v_x+v_y.*v_y+v_z.*v_z);
end