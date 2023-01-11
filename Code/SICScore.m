
function score = SICScore(trace, edges)
    %Calculates the SIC for a given model.

    N = length(trace);
    sigma_k = 0;
    
    for i = (1:length(edges)-1)
        lb = edges(i);
        ub = edges(i+1);
        if ub-lb<5
            continue
        end
        
        %Crop trace and calculate terms for SIC
        trace_crop = (trace(lb:ub))';
        error = trace_crop - mean(trace_crop);
        sigma_k = sigma_k + sum((error).^2);
    
    end
    
    sigma_k = sigma_k/N;
    k = length(edges)-1;
    score = (k+2)*log(N) + N*log(sigma_k);

    
end