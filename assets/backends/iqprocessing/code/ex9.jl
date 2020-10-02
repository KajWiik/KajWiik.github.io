# This file was generated, do not modify it. # hide
figure() # hide
subplot(121)
plotspec(i, fs/4, (-15, 5))
title("Filtered I channel")
subplot(122)
plotspec(q, fs/4, (-15, 5))
title("Filtered Q channel")
tight_layout(pad=2.0)
savefig(joinpath(@OUTPUT, "iqspectrum.svg")) # hide