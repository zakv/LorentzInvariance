times=generate_event_times();times=times(1:4);
mex -O CFLAGS="\$CFLAGS -std=c99" -I../../../aephem-2.0.0/src/ cmb_velocity.c ../../../aephem-2.0.0/src/.libs/libaephem.so
[v_x,v_y,v_z]=datenum_to_cmb_velocity(times);
speeds=sqrt(v_x.^2+v_y.^2+v_z.^2);

disp('Input times:');
disp(times);
disp('Velocity x-components (m/s)');
disp(v_x);
disp('Velocity y-components (m/s)');
disp(v_y);
disp('Velocity z-components (m/s)');
disp(v_z);
disp('Speeds (m/s)');
disp(speeds);