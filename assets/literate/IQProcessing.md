<!--This file was generated, do not modify it.-->
# Digitizing IQ streams

Let's first load some libraries

```julia:ex1
using DSP, PyPlot
```

Set up sampling rate

```julia:ex2
const GHz = 1e9
fs = 32GHz;
```

Signal generation

```julia:ex3
h = remez(35, fs.*[0, 0.2, 0.25, 0.5], [0.5, 1], Hz = fs);
rf_sig = randn(1000000);
t = range(0, step = 1/fs, length = length(rf_sig))
rf_sig = rf_sig + 0.2*sin.(2*pi*6GHz*t) + 0.1*sin.(2*pi*9GHz*t);
rf_sig = filt(h, rf_sig);
```

Function for plotting spectrum

```julia:ex4
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
```

```julia:ex5
figure() # hide
plotspec(rf_sig, fs, (-10, 10))
title("RF signal spectrum");
savefig(joinpath(@OUTPUT, "spectrum.svg")) # hide
```

\fig{spectrum}

```julia:ex6
lo_sig = 8GHz*t;
if_sig = rf_sig.*exp.(im*2*pi*lo_sig);
```

```julia:ex7
responsetype = Lowpass(3.8GHz, fs=fs)
designmethod = Butterworth(20)
i = filt(digitalfilter(responsetype, designmethod), imag(if_sig))
q = filt(digitalfilter(responsetype, designmethod), real(if_sig));
```

```julia:ex8
i = i[1:4:end]
q = q[1:4:end];
```

```julia:ex9
figure() # hide
subplot(121)
plotspec(i, fs/4, (-15, 5))
title("Filtered I channel")
subplot(122)
plotspec(q, fs/4, (-15, 5))
title("Filtered Q channel")
tight_layout(pad=2.0)
savefig(joinpath(@OUTPUT, "iqspectrum.svg")) # hide
```

\fig{iqspectrum}

```julia:ex10
c = i + q.*im;
```

```julia:ex11

plotspec(c, fs/4, (-20, 0));
title("Complex IF signal spectrum");
savefig(joinpath(@OUTPUT, "cspectrum.svg")) # hide
```

\fig{cspectrum}

