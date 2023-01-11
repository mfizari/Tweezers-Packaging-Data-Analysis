function length_missed = Calculate_lengthmissed(vp, vx, ipkg, lpkg, cal_params, fish_parameters, sr)

%length_missed is in bp

%% Force-velocity relationshhip from Liu et al Cell 2014
vforcedata = [2.8990228013029284, 93.77576181923347
                4.983713355048856, 100.4657676032756
                6.938110749185665, 85.6628816706749
                10, 78.31593046972512
                14.885993485342016, 65.88815489055983
                20.032573289902277, 61.866723492343766
                24.853420195439742, 55.79530579317485
                30.000000000000004, 47.474808974398016
                35.0814332247557, 40.277025175804454
                40.03257328990229, 36.07233096897929];

force = vforcedata(:,1); 
vmotor = vforcedata(:,2)./100;
p = fit(force, vmotor, 'Exp1'); 

%% Calculate

delay_time_on = fish_parameters.delay_time_on; %if 1, assume that tether starts packaging at the mid point of the delay time
tdelay = fish_parameters.tdelay;  %typical delay time - this should be a function argument
vbead_fish = fish_parameters.vbead_fish; %[V/s] Fishing bead movement speed
Vbump = cal_params.vbump; %depends on bead size
alpha=cal_params.alpha;

% 1. Calculate amount of packaging during force ramp
%   LengthPackaged_ForceRampDown

    t_miss = ipkg(1)/1e3; %this is the amount of time that the thing is ramping down
    framp = alpha*vx(1:ipkg(1)); %this is the force during the ramping down segment (NOTE: this is a little inaccurate because of the background difference)
    
    %Measure the velocity in the first 5s of packaging (non-zero force)
    % mean_background_difference = 1.26; %to account for the fact that we don't know the packaging force super accurately, I measured the mean fslip-5pN difference. 
    vinitial = sr*(lpkg(1) - lpkg(5*sr))/(5); %velocity in bp
    fpkg = (alpha*(mean(vx(ipkg(1):ipkg(5*sr)))));
    
    %Find the zero-force velocity based on vinitial
    vzero = vinitial * p.a*exp(-p.b*fpkg);
    
    %Find the velocity during the ramp
    vramp = vzero * p.a*exp(p.b*framp);

    % Integrate the curve to find the prefill error 
    if length(framp) > 2
        t = (1:length(vramp))/sr; %packaging time (s)
        LengthPackaged_ForceRampDown = trapz(t,vramp); %length packaged during movement in basepairs
    end


% 2. Calculate the amount of DNA packaged during the ramp from
%    ideal setpoint to real setpoint
%    LengthPackaged_ForceRampUp
    if mean(framp) > fpkg %If the setpoint was too high and the force increased past the force clamp value
    
        vbead_fc = max(diff(vp)); %Find the step size for the force clamp
        vbead_fc = sr*vbead_fc;  %Speed (V/s) of bead movement during force clamp mode
    
        dt_down = t(end) - t(1);
        dt_up = (vbead_fc/vbead_fish)*dt_down; %this is how long it takes to ramp up
        t_upramp = 1e-3:1e-3:dt_up;
    
        if ~isempty(t_upramp)
            f_upramp = flip(resample(framp,length(t_upramp),length(t))); %Resample so that t_upramp and F_upramp are the same size
    
            v_upramp = vzero * p.a*exp(p.b*f_upramp); %calculate velocity during ramp up
    
            if length(f_upramp) > 2
                LengthPackaged_ForceRampUp = trapz(t_upramp,v_upramp);
            end
        end
    
    end

%3. Calculate amount packaged during fishing, moving from bump
%   voltage to ideal set point voltage
%   LengthPackaged_Fishing
    dt_fish = ((vp(ipkg(1))-Vbump)/vbead_fish);
    LengthPackaged_Fishing =  vzero*dt_fish;
    
    %4. If there were some delay time, calculate the amount packaged
    %   during that delay.
    %   LengthPackaged_DelayTime
    if delay_time_on == 1
    
       dt_delay = tdelay/2; %tether forms halfway during delay time on average (not really since the activity decreases with time but assume it does)
       LengthPackaged_DelayTime =  vzero*dt_delay;
    else
        LengthPackaged_DelayTime = 0;
    
    end


% Add total amount of missed length packaged
length_missed = LengthPackaged_ForceRampDown+LengthPackaged_ForceRampUp+LengthPackaged_Fishing+LengthPackaged_DelayTime;

    