# Beam switching efficiencies
\toc

Beam switching efficiencies are presented below for a Cassegrain antenna where subreflector subtends an angle of 14$^{\circ}$ with an edge taper of 12 dB (e.g. in Metsähovi Radio Observatory).The efficiencies are calculated for different chopper blade radii and distances from beam waist to chopper blade. Ohmic losses are not included. Also no mechanical constraints like cabin size are not taken into accunt. E.g. it is very clear that the largest diameter (1m) does not fit into the Metsähovi cabin.

$2\omega_0$ values are calculated with signal blanking when $2\omega_0$ contour coincides the chopper blade. Going beyond the $2\omega_0$ radius (beam truncation) is very difficult to simulate and effects will in any case be nonlinear, i.e. the signal does not necessarily decrease linearly with increasing truncation, see \cite{goldsmith2009} section 8.5. This article is good also for general tutorial for Gaussian beams and reimaging optics.

Geometrical optics values are calculated by integrating the reflected intensity from the chopper blade. No diffraction effects are taken into account. Beam truncation effects are certainly reducing efficiency from these values and these have mainly a curiosity value. 

## Efficiency plots for signal blanking at $2\omega_0$
### 22 GHz $2\omega_0$
\fig{./eff_2w0_22.svg}

### 37 GHz $2\omega_0$
\fig{./eff_2w0_37.svg}

### 43 GHz $2\omega_0$
\fig{./eff_2w0_43.svg}

### 86 GHz $2\omega_0$
\fig{./eff_2w0_86.svg}

## Efficiency plots with geometrical optics
### 22 GHz geometrical optics
\fig{./eff_go_22.svg}

### 37 GHz geometrical optics
\fig{./eff_go_37.svg}

### 43 GHz geometrical optics
\fig{./eff_go_43.svg}

### 86 GHz geometrical optics
\fig{./eff_go_86.svg}

# $2\omega_0$ contours on chopper blade

Plots of $2\omega_0$ contours on the chopper blade with different combinations of focus and chopper blade radii are presented in the table below. Efficiencies for the given combination can be seen by placing cursor over the link. $2\omega_0$ angle at 22 GHz (when it is defined) is shown as a dashed line.

\textinput{chopper/blade.md}

# Switching plots 

Plots showing switching behaviour of geometrical optics and $2\omega_0$ blanking are shown in the table below for different frequencies.

\textinput{chopper/switch.md}

# Conclusions
The values were calculated even for chopper diameters (1m) than can not fit to the Metsähovi cabin. It can be seen that with the largest chopper that fits (theoretically) between the receiver beds (D = 580mm, R = 290mm), the efficiency at the lowest frequency (22 GHz) is a bit lower than 30% and even at 43 GHz it is less than 70%.

The only way to improve efficiencies with a quasioptical chopper is to reduce the beam waist **before** the chopper blade. Whether this is mechanically possible has not been studied yet.

# References
\biblabel{goldsmith2009}{Goldsmith et al. (2009)} **Paul F. Goldsmith and Michael Seiffert** [A Flexible Quasioptical Input System for a Submillimeter Multiobject Spectrometer](https://iopscience.iop.org/article/10.1086/603652), Publications of the Astronomical Society of the Pacific, Volume 121, Number 881

# Appendix: Code

Julia code that was used to calculate the efficiencies.

\textinput{./parallelefficiency.md}
