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