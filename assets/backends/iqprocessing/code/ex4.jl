# This file was generated, do not modify it. # hide
function plotspec(sig, fs, limits)
    n = div(length(sig), 1024)
    noverlap = div(n, 2)
    pgram = welch_pgram(sig, n, noverlap)
    f = freq(pgram)
    p = power(pgram)
    i = sortperm(f)
    plt = plot(fs*f[i]/GHz, pow2db.(p[i]))
    ylim(limits...)
    xlabel("Frequency [GHz]")
    ylabel("Power [dB]")
    return plt
end

figure() # hide

plotspec(rf_sig, fs, (-10, 10))
title("RF signal spectrum");

savefig(joinpath(@OUTPUT, "spectrum.svg")) # hide