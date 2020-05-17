# This file was generated, do not modify it. # hide
figure() # hide
plotspec(rf_sig, fs, (-10, 10))
title("RF signal spectrum");
savefig(joinpath(@OUTPUT, "spectrum.svg")) # hide