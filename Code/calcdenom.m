function [denom] = calcdenom(f)
%Calculate denom in WLC model with typical DNA parameters
    
    %f is in pN, vector or scalar
    P = 50; %persistence length
    S = 1100; 
    kT = 4.14;
    
    denom = 1 - (kT./(4*P*f)).^(1/2) + f./S ; 
end


