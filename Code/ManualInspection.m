function outputs = ManualInspection(vp,vx, inputs)

    if inputs.inspect_multipletethers %Inspect multiple tethers 
    
         locs =inputs.locs;
        ax1 = subplot(2,1,1);
        plot(vp);
        
        ax2 = subplot(2,1,2);
        hold on
        h = plot(vx);
        xline(locs, 'r')
        hold off
        linkaxes([ax1,ax2],'x')
        title('Zoom to inspect multiple tethers, press any key when finished');
        zoom on; pause; zoom off;
        title(['Press ENTER to keep trace'])
        key = getkey(1);
        if key==13
            outputs.inspectmultipletether = false(1);
        else
             outputs.inspectmultipletether = true(1);
        end
        clf
    else
        outputs.inspectmultipletether = inputs.inspect_multipletethers;
    
    end


    if inputs.inspect_ramp%Inspect iramp
    
        iramp = inputs.iramp;
    
        ax1 = subplot(2,1,1);
        h = plot(vp);
        ax2 = subplot(2,1,2);
        hold on
            plot(vx,'b')
            plot(1:iramp, vx(1:iramp),'g')
        hold off
        linkaxes([ax1,ax2],'x')
        title('Zoom to inspect irmamp, press any key when finished');
        zoom on; pause; zoom off;
        title(['Press ENTER to re-select iramp endpoint'])
        key = getkey(1);
        if key==13
            [x,~] = MagnetGInput(h,1);
            iramp_new = x;
            outputs.iramp = iramp_new;
            outputs.inspect_ramp = false(1);
        else
            outputs.iramp = iramp;
            outputs.inspect_ramp = false(1);
        end
        clf
    else
        outputs.inspect_ramp = inputs.inspect_ramp;
        outputs.iramp = inputs.iramp;
    end



    if inputs.inspect_background %Inspect iramp
    
        t_bg= inputs.tbg;
        vx_vbg= inputs.vbg;
    
    
        ax1 = subplot(2,1,1);
            plot(vp);
        ax2 = subplot(2,1,2);
            hold on
            plot(t_bg, vx_vbg,'r')
            h = plot(vx);
            hold off
        linkaxes([ax1,ax2],'x')
        title('Zoom to inspect background, press any key when finished');
        zoom on; pause; zoom off;
        title(['Press SPACE to re-select background'])
        key = getkey(1);
        if key==13

            [x,~] = MagnetGInput(h,2);
            t_bg_new = [x(1):x(2)]';
            outputs.tbg = t_bg_new;
            outputs.vbg = vx(t_bg_new);
            outputs.meanvbg = trimmean(vx(t_bg_new),10);
            outputs.inspectvbg = false(1);
        else
            outputs.tbg = inputs.tbg;
            outputs.vbg = inputs.vbg;
            outputs.meanvbg = inputs.meanvbg;
            outputs.inspectvbg = false(1);
        end
        clf
    else
        outputs.tbg = inputs.tbg;
        outputs.vbg = inputs.vbg;
        outputs.meanvbg = inputs.meanvbg;
        outputs.inspectvbg = inputs.inspect_background;
    
    end