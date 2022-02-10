t = ((1:9000)/30)';
rmsAll = zeros(4, length(sigma), neuronN);

for si = 1:length(sigma)
    for n = 1:neuronN
        rawTrace = neuronDfNoised(:,n,si);  
        
        y = detrend(rawTrace, 1);
        bdetr = rawTrace - y;
        
        g = fittype('a*exp(-x/b)+c');
        bfit = fit(t, rawTrace, g, 'StartPoint', [10 1000 10]);

        bkde = baseline_kde(rawTrace, 30, 100);

        [~,~,~,bcor,~,~] = baselineCorrector2_test(rawTrace, 30);
                
        borig = A*exp(-(1:length(rawTrace))/B) + C;

        rmsAll(1, si, n) = rms(borig'-bdetr);
        rmsAll(2, si, n) = rms(borig'-(bfit.a*exp(-t/bfit.b)+bfit.c));
        rmsAll(3, si, n) = rms(borig'-bkde);
        rmsAll(4, si, n) = rms(borig'-bcor');
    end

    figure
    plot(t, rawTrace)
    hold on
    plot(t, borig, 'LineWidth', 1.5)
    plot(t, bdetr, 'LineWidth', 1.5)
    plot(t, bfit.a*exp(-t/bfit.b)+bfit.c, 'LineWidth', 1.5)
    plot(t, bkde, 'LineWidth', 1.5)
    plot(t, bcor, 'LineWidth', 1.5)
    legend('raw data', 'true baseline', 'detrend', 'fit', 'kde', 'baselineCorrector')
    hold off
end
%%
h = heatmap(rmsAll(:,:,1));
h.XDisplayLabels = sigma;
xlabel('sigma')
h.YDisplayLabels = {'detrend', 'fit', 'KDE', 'baselineCorrector'};
ylabel('method')
title('Baseline estimation RMSE')

%%
h = heatmap(mean(rmsAll, 3));
h.XDisplayLabels = sigma;
xlabel('sigma')
h.YDisplayLabels = {'detrend', 'fit', 'KDE', 'baselineCorrector'};
ylabel('method')
title('Baseline estimation RMSE')
% figure
% plot(t, rawTrace)
% hold on
% plot(t, borig, 'LineWidth', 1.5)
% plot(t, bdetr, 'LineWidth', 1.5)
% plot(t, bfit.a*exp(-t/bfit.b)+bfit.c, 'LineWidth', 1.5)
% plot(t, bkde, 'LineWidth', 1.5)
% legend('raw data', 'true baseline', 'detrend', 'fit', 'kde')

%% single trace test
y = detrend(rawTrace, 1);
bdetr = rawTrace - y;

g = fittype('a*exp(-x/b)+c');
bfit = fit(t, rawTrace, g, 'StartPoint', [10 1000 10]);

bkde = baseline_kde(rawTrace, 30, 100);

[~,~,~,bcor,~,~] = baselineCorrector2_test(rawTrace, 30);

plot(t, rawTrace)
hold on
plot(t, bdetr, 'LineWidth', 1.5)
plot(t, bfit.a*exp(-t/bfit.b)+bfit.c, 'LineWidth', 1.5)
plot(t, bkde, 'LineWidth', 1.5)
plot(t, bcor, 'LineWidth', 1.5)
legend('raw data', 'detrend', 'fit', 'kde', 'baselineCorrector')
hold off

