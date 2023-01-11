function [t_bg, vx_vbg, mean_vbg, inspect_background,varargout] = GetBackgroundVoltage(vp,vx,sr, locs)
% Automatically find background
%Since packaging occurs between ~-1V and -7V for phi29, we find the
%vx background where the trap position is between these two values
%We also require that this occurs after the first force peak
%
% Inputs:
%         vp: piezo voltage
%         vx: psd voltage
%         sr: sampling rate
%         locs: locations of automatically detected force peaks (index)

%     if length(locs) >= 1 %If there were  peaks located ... 
        %Find the range of trap position over the packaging segment:
        %From 1 to the location of the firstpeak-1s
    ipkg_est = 1:(locs(1)-sr); ipkg_est = ipkg_est';
    vp_range = [min(vp(ipkg_est)), max(vp(ipkg_est))]; %min is the smaller signed number
        %Find range where vx is equal to that, after the last peak
    lastpkloc = locs(end);
%     end

    %Calculate vp,vx, and index after last point to end
    tend = [lastpkloc:length(vp)]';
    vp_end = vp(tend);
    vx_end = vx(tend);

    %Find regions where vp covers same range as packaging rate
    %If it doesn't, these come out as empty
    vp_vbg = vp_end(vp_end > vp_range(1) & vp_end < vp_range(2));
    varargout{1} = vp_vbg;
    vx_vbg = vx_end(vp_end > vp_range(1) & vp_end < vp_range(2));
    t_bg = tend(vp_end > vp_range(1) & vp_end < vp_range(2));
    
    if isempty(vp_vbg)
        inspect_background = true(1);
        mean_vbg = trimmean(vx(end-sr:end),10);
    else
        inspect_background = false(1);
        mean_vbg = trimmean(vx_vbg,10);
    end
end