# Tweezers-Packaging-Data-Analysis

This repository contains MATLAB code used for analysis of data from optical tweezer measurements of DNA packaging by bacteirophage phi29. The analysis code presented here is the framework for analysis of experimental data - each experiment will have it's own unique characteristics that will call for adjustments to be made. <br/>

**Instrumentation**: Measurements are done using a dual-trap optical tweezer instrument. One trap's lateral position is controlled using a piezoelectric mirror and the control signal to the mirror is recorded (`vp`). Beam deflection and intensity is captured by a silicon position sensing detector (PSD), amplified, and passed through a 300 Hz low-pass filter (x-displacement reocrded as `vx`). The code in this repository and the raw data files correspond to measurements in "force-clamp" mode, where the position of the movable trap is adjusted to keep the force on the DNA tether constant. The LabVIEW code that controls the instrument and handles data acquisition runs at 1 kHz in force clamp mode.  

This repository contains two directories:

#### Code<br/>
Contains host of MATLAB code (`.m` files) for formatting and analysis of packaging data. The description of how to use each function is found in the main notebook: `Packaging data analysis notebook.ipynb`


#### Data
Contains a handful of force-clamp position and force measurements for different complexes for testing analysis code. 

## Required toolboxes in MATLAB
Signal Processing Toolbox
