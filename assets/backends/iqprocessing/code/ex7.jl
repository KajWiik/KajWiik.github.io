# This file was generated, do not modify it. # hide
responsetype = Lowpass(3.8GHz, fs=fs)
designmethod = Butterworth(20)
i = filt(digitalfilter(responsetype, designmethod), imag(if_sig))
q = filt(digitalfilter(responsetype, designmethod), real(if_sig));