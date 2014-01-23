times=generate_event_times();times=times(1:4);
mex -O CFLAGS="\$CFLAGS -std=c99" -I../../../aephem-2.0.0/src/ cmb_velocity.c ../../../aephem-2.0.0/src/.libs/libaephem.so
[speed,theta,phi]=datenum_to_cmb_velocity(times);

disp('Input times:');
disp(times);
disp('Speed (m/s)');
disp(speed);
disp('Trap angle relative to CMB velocity (degrees)');
disp(theta);
disp('Rotation south-east from zenith (degrees)');
disp(phi);