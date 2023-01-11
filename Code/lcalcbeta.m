function [f,l] = lcalcbeta(vxcrop, vpcrop,cal_params)

    f = cal_params.alpha*abs(mean(vxcrop));
    g = cal_params.gamma; %compliance nm/pN
    vb = cal_params.vbump; %volts
    x = cal_params.beta*(vpcrop - vb) - g*f;
    denom = calcdenom(f);
    l = x/denom; % in nm
    l = l./0.34; % in bp
    l = l/1000; % in kbp

end