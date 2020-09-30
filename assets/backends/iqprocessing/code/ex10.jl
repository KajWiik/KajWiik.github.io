# This file was generated, do not modify it. # hide
subplot(111)
plotspec(c, fs/4, (-20, 0));
title("Complex IF signal spectrum");
savefig(joinpath(@OUTPUT, "cspectrum.svg")) # hide