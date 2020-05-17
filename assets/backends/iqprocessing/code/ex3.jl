# This file was generated, do not modify it. # hide
h = remez(35, fs.*[0, 0.2, 0.25, 0.5], [0.5, 1], Hz = fs);
rf_sig = randn(1000000);
t = range(0, step = 1/fs, length = length(rf_sig))
rf_sig = rf_sig + 0.2*sin.(2*pi*6GHz*t) + 0.1*sin.(2*pi*9GHz*t);
rf_sig = filt(h, rf_sig);