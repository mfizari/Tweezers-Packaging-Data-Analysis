function [iramp, inspect_ramp] = GetRampingIndex(vx, sr, ramp_params)

%This function detects force ramping that can happen at the beginning of
%the measurement if the trap overshoots the force clamp point. 
%It does this by first checking if difference in  vx value in the first 100ms of
%measurement and the vx value at 3s is greater than 1SD of the normal vx
%noise. If yes, it starts sliding a window (win) by a factor of the win
%size(slide) until the vx value is within a factor of clamp_cutoff of the
%"mean" vx value, then it outputs the index at which they are ~equal. 
%If the vx value is initially larger than 1.3*mean(vx), it marks for manual
%inspection so you can be sure it did a good job. 
%
%
% Inputs:
%         vx: psd voltage
%         sr: sampling rate
%         ramp_params (structure, contains .win, .slide, and .clampcutoff)
% Some reasonable working values for typical low-res data:
% ramp_params.win = sr/50; %window size in #datapts for ramp detection
% ramp_params.slide = 0.5; %factor by which to slide ramp detection window
% ramp_params.clampcutoff = 0.005; %sensitivity parameter for ramp detection

%Initialize parameters
win = ramp_params.win;       %window size in datapoints
slide = ramp_params.slide;   %sliding factor in datapoints
clamp_cutoff = ramp_params.clampcutoff; %detection sensitivity
winsize = floor(win*slide);

%Automatically partition possible force drop in beginning of trace
iramp = 1; %otherwise chop at first data point

% Trigger start point if initial vx values are too large
CheckVxStartSize = mean(vx(1:10))-mean(vx(3*sr:3*sr+10)) >= std(vx(3*sr:1:3*sr+10)) ;

if CheckVxStartSize
    vx_clamp = mean(vx(3*sr:5*sr)); %Calculate value of force clamp
    for ts=1:winsize:3*sr %scan the first 3 seconds for dropping force
        tbin = [ts:ts+win]';
        vmean = mean(vx(tbin));
        if abs(vx_clamp-vmean) < clamp_cutoff*vx_clamp
            iramp = tbin(1); 
            break
        end
    end
end

%If necessary chopping was detected, mark for inspection
if mean(vx(1:iramp)) > 1.3*mean(vx)
    inspect_ramp = true(1);
else
    inspect_ramp = false(1);
end

end
