# This file was generated, do not modify it. # hide
function plotspec(sig, fs, limits)
    n = div(length(sig), 1024)
    noverlap = div(n, 2)
    pgram = welch_pgram(sig, n, noverlap)
    f = freq(pgram)
    p = power(pgram)
    i = sortperm(f)
    plot(fs*f[i]/GHz, pow2db.(p[i]))
    ylim(limits...)
    xlabel("Frequency [GHz]")
    ylabel("Power [dB]")
end;