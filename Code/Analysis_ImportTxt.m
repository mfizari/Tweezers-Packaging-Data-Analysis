cfold = '\Code'; 
dfold_raw = '';
depfold = ';
cd(cfold)

% Parameters
duration_cutoff = 0; %length cutoff
sr = 1e3; %sampling rate
ramp_params.win = sr/50; %window size in #datapts for ramp detection
ramp_params.slide = 0.5; %factor by which to slide ramp detection window
ramp_params.clampcutoff = 0.005; %sensitivity parameter for ramp detection

%Calibration parameters
cal_params.alpha  = 38.5;
cal_params.beta  = 990;
cal_params.gamma  = 15;
cal_params.vbump  = -9;

fish_parameters.delay_time_on=1; %if 1, assume that tether starts packaging at the mid point of the delay time
fish_parameters.tdelay=0.2;  %typical delay time - this should be a function argument
fish_parameters.vbead_fish=10; %[V/s] Fishing bead movement speed


%Get filenames 
[piezofiles, psdfiles] = GetRawFileNames(cfold, dfold_raw);

for i=1:length(piezofiles)

    %Load data
    cd(dfold_raw)
    vp = load(piezofiles{i});
    vx = load(psdfiles{i});
    cd(cfold)

    if length(vp)/sr >= duration_cutoff %Make sure the file is long enough (in time)

        %Calculate time array
        t = (1:length(vp))'/sr;

        %Get peak locations - if inspect, manually select pkg region, or
        %toss trace
        [locs, inspect_multipletethers] = GetPeakLocs(vp,vx, sr);

        %Get ramping index - if inspect, manually select ramp region
        [iramp, inspect_ramp] = GetRampingIndex(vx, sr, ramp_params);

        %Get background voltage ad piezo voltage arrays - if inspect
        %manually select vbg
        [t_bg, vx_vbg, mean_vbg, inspect_background, vp_vbg] = GetBackgroundVoltage(vp,vx,sr, locs);

        inputs.inspect_multipletethers = inspect_multipletethers;
        inputs.locs =locs;
        inputs.inspect_ramp = inspect_ramp;
        inputs.iramp = iramp;
        inputs.inspect_background = inspect_background;
        inputs.tbg = t_bg;
        inputs.vbg=vx_vbg;
        inputs.meanvbg = mean_vbg;
        outputs = ManualInspection(vp,vx, inputs);


        %Save in new directory as mat file with variables
        if ~outputs.inspectmultipletether %decided to keep trace!
            vbg = outputs.meanvbg;
            vx = vx-vbg; %subtract the background voltage

            %Now we need to crop out the packaging region
%             crop=[iramp:locs(1)-sr]'; %this is a start, but doesn't include possible terminal slipping
            [~, imin] = min(smoothdata(vp,'gaussian',100));
            ipkg=[iramp:imin]';
            [fpkg,lpkg] = lcalcbeta(vx(ipkg), vp(ipkg),cal_params);

            length_missed = Calculate_lengthmissed(vp, vx, ipkg,lpkg, ...
                cal_params, fish_parameters, sr);

            %Now save everything in a mat file
            cd(depfold)
            fname = [piezofiles{i}(1:8),'.mat'];
            save(fname, 'vp', 'vx', 'vbg', 'fpkg', 'lpkg','ipkg', 'length_missed')
            cd(cfold)


        end
        

    end
end
