function SGdistFit(data, ploton)

%input: data - 1st derivative estimate from Savitsky Golay filter

%Define the mixutre PDF
pdf_binorm = @(x,p,mu1,mu2,sigma1,sigma2) p*normpdf(x,mu1,sigma1) + (1-p)*normpdf(x,mu2,sigma2);

%Define starting point. 1: pause/slip peak, 2:packaging peak
p0 = 0.5;  %probability of getting a pause (initial guess)
m0 = [0, median(data)];        %0 mean for pausing, higher vel for packaging
s0 = 50; %assume same std. dev. to start
start = [p0 m0 s0 s0];

%Set bounds and perform fit
lb = [0 -Inf -Inf 0 0]; %bounds for the mixing prob, mean, and sigma
ub = [1  30 Inf Inf Inf]; %Upper lmit based on ctrl data for ~1s window
options = statset('MaxIter',1e3); %set large number of max iterations
dist_params = mle(vels,'pdf',pdf_binorm,'Start',start,'LowerBound',lb, ...
    'UpperBound',ub,'Options',options);

%Plot hisotgram
if ploton
    figure()
    hold on
    histogram(vels,'Normalization','pdf')
    xplot = linspace(1.1*min(vels),1.1*max(vels),100);
    pdfgrid = pdf_normmixture(xplot, dist_params(1),dist_params(2), ...
        dist_params(3),dist_params(4),dist_params(5));
    plot(xplot,pdfgrid,'r-', 'LineWidth',1.4)
    hold off
    xlabel('data')
    ylabel('PDF')
    legend('Velocities','Fitted PDF')
    title('Bimodal velocity distribution fitted')
end