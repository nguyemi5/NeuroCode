%% setup params + load data
% load([dataDir, '\simulatedData.mat'])
t = (1:9000)/30;
thrSteps = 40;

%% deconvolve
foopsiC = zeros(9000,neuronN, length(sigma));
foopsiS = zeros(9000,neuronN, length(sigma));
neuronDfNb = zeros(9000,neuronN, length(sigma));

for i=1:length(sigma)
    parfor n=1:neuronN
        if addedBaseline
            b = baseline_kde(neuronDfNoised(:,n,i));
            neuronDfNb(:,n,i) = (neuronDfNoised(:,n,i)-b)./b*100;
            [c,s,options] = deconvolveCa(neuronDfNb(:,n,i), 'ar1', 0.95, 'method', 'constrained_foopsi', 'thresholded', 'smin', 5);
        else
            [c,s,options] = deconvolveCa(neuronDfNoised(:,n,i), 'ar1', 0.95, 'method', 'constrained_foopsi', 'thresholded', 'smin', 5);
        end
        foopsiC(:,n,i) = c;
        foopsiS(:,n,i) = s;
          
    end
end

%% plot deconvolved spiketrain
% t = (1:9000)/30;
n = 10;
figure
axes = [];
for i = 1:3;length(sigma)
    ax = subplot(4, 1, i);%subplot(length(sigma)+1, 1, i);
    axes = [axes ax];
    plot(t, foopsiS(:,n,i))
    title(sprintf('deconvolved from noised signal with sigma^2 = %d', sigma(i)))
end
% subplot(length(sigma)+1, 1, length(sigma)+1)
subplot(4, 1, 4);
plot(neuronSpikes(:,n))
title('ground truth')
linkaxes(axes)

%% analyze TPR and FDR
disp('analysis')
% t = (1:9000)/30;
neuronSpikeTimes = cell(neuronN,1);
spikeThrs = linspace(0, max(max(max(foopsiS))), thrSteps);
foopsiSpikeTimes = cell(neuronN, length(sigma));
tp = zeros(neuronN, length(sigma), length(spikeThrs));
fp = zeros(neuronN, length(sigma), length(spikeThrs));
fn = zeros(neuronN, length(sigma), length(spikeThrs));
ts = zeros(neuronN, 1);

for thr=1:length(spikeThrs)
    spikeThr = spikeThrs(thr);
    fprintf('spike thr = %d\n', spikeThr)
    for n = 1:neuronN
%         fprintf('neuron %d:\n', n)
        neuronSpikeTimes{n} = t(neuronSpikes(:,n)>0);
        ts(n) = length(neuronSpikeTimes{n});
        for si = 1:length(sigma)
            foopsiSpikeTimes{n, si} = t(foopsiS(:,n,si)>spikeThr);
            distM = abs(neuronSpikeTimes{n} - foopsiSpikeTimes{n, si}');
            [~,i]=sort(min(distM));
            
            while all(size(distM)>1)
                [d, i] = min(distM);
                [d, j] = min(d);
                if d<0.2
                    tp(n, si, thr) = tp(n, si, thr) + 1;
                else
                    break
                end
                distM = [distM(1:i(j)-1,:); distM(i(j)+1:end,:)];
                distM = [distM(:,1:j-1) distM(:,j+1:end)];
            end
            fp(n,si,thr) = length(foopsiSpikeTimes{n,si}) - tp(n, si, thr);
            fn(n,si,thr) = ts(n) - tp(n,si,thr);
        end
    end
end

%%
tpr = tp./sum(neuronSpikes>0)';
fdr = fp./(fp+tp);
mtpr = mean(tpr);
mfdr = mean(fdr);
missrate = fn./ts;
mmissrate = mean(missrate);
prec = 1-mfdr;
prec = reshape(prec, size(prec,2), []);
mtpr = reshape(mtpr, size(mtpr,2), []);
mmissrate = reshape(mmissrate, size(mmissrate,2), []);
mfdr = reshape(mfdr, size(mfdr,2), []);

% %%
% figure
% for si = 1:length(sigma)
%     plot(prec(si,:), mtpr(si,:))
%     hold on
% end
% 
% title(sprintf('precision-recall analysis for sigma in [%d, %d]', sigma(1), sigma(end)))
% xlabel('1-FDR (precision)')
% ylabel('TPR (recall)')
% 
% figure
% surf(prec, mtpr, repmat(sigma', [1, 151]))
% xlabel('1-FDR (precision)')
% ylabel('TPR (recall)')
% zlabel('sigma')
% title(sprintf('precision-recall analysis for sigma in [%d, %d]', sigma(1), sigma(end)))
%%
figure
for si = 1:length(sigma)
    plot(mmissrate(si,:), mfdr(si,:))
    hold on
end

title(sprintf('Miss-FDR analysis for sigma in [%d, %d]', sigma(1), sigma(end)))
ylabel('beta = false discovery rate (type II error)')
xlabel('alpha = miss rate (type I error)')

figure
surf(mmissrate, mfdr, repmat(sigma', [1, length(spikeThrs)]))
title(sprintf('Miss-FDR analysis for sigma in [%d, %d]', sigma(1), sigma(end)))
ylabel('beta = false discovery rate (type II error)')
xlabel('alpha = miss rate (type I error)')
zlabel('sigma')

