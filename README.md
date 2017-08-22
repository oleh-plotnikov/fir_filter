# fir_filter
Digital Bandpass FIR filter with serial architecture.

In this realization of digital FIR filter are used 6-bit coefficients of impulse response in signed fixed-point format. 
The word “serial” means that each data sample at filter’s output calculated iteratively (serially) during several clock cycles. Digital FIR filter with serial structure have one multiplication and one addition per clock cycle.
