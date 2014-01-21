disp('Input times:');
times=generate_event_times();
times=times(1:4);
disp(times);
mex -O CFLAGS="\$CFLAGS -std=c99" -I../../../aephem-2.0.0/src/ moon_position.c ../../../aephem-2.0.0/src/.libs/libaephem.so
[altitude_angles,azimuthal_angles,distances]=datenum_to_moon_position(times);
disp('Altitude Angles (degrees)');
disp(altitude_angles);
disp('Azimuthal Angles (degrees)');
disp(azimuthal_angles);
disp('Distances (AU)');
disp(distances);