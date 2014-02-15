function v = st_to_CMBspeed_paper(t)

utc = st2utc_ch(t);
v = utc_to_CMBspeed_paper(utc);