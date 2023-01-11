function cutpoint = AddEdge(trace)

    score = SICScore(trace, [1,length(trace)]);
    
    cutpoint = 0;
    
    %Try adding a step every addpt data points
    addpt=100;
    for k = 10:addpt:length(trace)-100
        score_add = SICScore(trace, [1,k, length(trace)]);
        if score_add < score
            score = score_add;
            cutpoint = k;
            
        end
    end
    
end