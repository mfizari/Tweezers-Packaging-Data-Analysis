function [locs, inspect_multipletethers] = GetPeakLocs(vp,vx, sr, varargin)
% Operating note: Traces should have their tethers broke after t=5s, and any 
% force ramp at the beginning should take less than 5s
% 
% This function finds "peak" locations for triaging multiple tether traces
% Given a vx dbl array and the sample rate sr, this outputs peak
% locs, the index in vx where peaks are found, and inspect_multipletethers
% which is true if more than one sufficiently separate peak was found
%
% If one or no force increase is detected, inspect_multipletethers is false
% If no peaks are found, locs = []
%
% You can optionally put in the parameters assigned below
%     tramp: max time ramping would run
%     tscan: time bounds inside which to scan for force clamp value
%     peakheight: reasonable min. height of a peak
%     peakprominence: reasonable min. prom of a peak
%     gap_cutoff: peaks with separations smaller than this will be counted as one peak


%Assign parameters
if ~isempty(varargin)
    tramp = varargin{1}.tramp;              
    tscan = varargin{1}.tscan;
    peakheight = varargin{1}.peakheight;
    peakprominence = varargin{1}.peakprominence;
    gap_cutoff = varargin{1}.gap_cutoff;
else
    tramp = 5;
    tscan = [3,4];
    peakheight = 0.1;
    peakprominence = 0.05;
    gap_cutoff = 0.5;

end


% Assign peaks if vx increases, otherwise output []
vx_postramp = vx(tramp*sr:end);
vx_fclamp = mean(vx(tscan(1)*sr:tscan(2)*sr));

if any( vx_postramp > vx_fclamp + peakheight) 
    [pks,locs] = findpeaks(smoothdata(vx,'gaussian', sr/20),...
        'MinPeakHeight', vx_fclamp + peakheight,...
        'MinPeakProminence', peakprominence);
else
    pks = []; locs = [];
end
            

%Calculate max separation between peaks - true multiple tether
%traces will have peaks that are fairly separate
if length(pks) > 1
    gaps = abs(diff(vp(locs)));
    if max(gaps) >= gap_cutoff
        inspect_multipletethers = true(1);
    else
        inspect_multipletethers = false(1);
    end
elseif length(pks)==1
    inspect_multipletethers = false(1);
elseif isempty(pks)
    lastpkloc = findchangepts(smoothdata(vx(tramp*sr:end), 'gaussian', sr/50));
    lastpkloc = lastpkloc(1)+tramp*sr;
    locs = lastpkloc;
    inspect_multipletethers = false(1);
end

% Should have no peaks detected because of ramping (early stages)
locs(locs < tramp) = []; 
    
end