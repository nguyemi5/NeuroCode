subject = '430';
% FOV = 19;
sessions = {'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'};
FOVs = [1; 1; 1; 1; 1; 2; 2; 1];
FOVRef = [2];
sessionRef = 'F3';
% FOVRef = [14 19 44 49];
% FOVs = [11 19 47 52;    % F1
%         12 17 51 56;    % F2
%         14 19 44 49;    % F3
%         12 20 51 58;    % F4
%         12 17 44 48;    % F5
%         14 19 41 46;    % F6?
%         13 18 44 50;    % F7
%         12 17 34 38];    
% session = 'F8';


for f=7:length(sessions)
    session = sessions{f};
    for iFOV = 1%:4
        FOV = FOVs(f, iFOV)
        FOVr = FOVRef(iFOV);
        %%
        if strcmp(session, sessionRef)
            d = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*%s\\file_*%05d_aligned*.mat', subject, subject, session, FOVr));
            load(sprintf('%s\\%s', d.folder, d.name));
            d = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*%s\\krouzky_%05d.mat', subject, subject, sessionRef, FOVr));
            load(sprintf('%s\\%s', d.folder, d.name));
            maskStructure = maskStructInt;
            neuronN = length(maskStructure);
            reidentificationRecord = 99*ones(neuronN,1);
        else
            d = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*%s\\file_*%05d_aligned*.mat', subject, subject, session, FOV));
            load(sprintf('%s\\%s', d.folder, d.name));
            d = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*%s\\%sFOV%05d.mat', subject, subject, sessionRef, session, FOVr));
            load(sprintf('%s\\%s', d.folder, d.name));
            d = dir(sprintf('\\\\neurodata2\\Large data\\Monika 2p\\VIP_tdT\\*%s*\\*%s*%s\\%sFOV%05dVARP.mat', subject, subject, sessionRef, session, FOVr));
            load(sprintf('%s\\%s', d.folder, d.name));
        end
    
    
        %%
        neuronDf = zeros(neuronN, 9000);
        neuronDf0 = zeros(neuronN, 9000);
        base = zeros(neuronN, 9000);
        data = reshape(dataset.aligned, 512*512, 9000);
        foopsiC = zeros(9000,neuronN);
        foopsiS = zeros(9000,neuronN);
        
        for n=1:neuronN
            neuronDf0(n, :) = mean(data(maskStructure(n).WCPixList, :), 1);
        end
    %%
        for n=1:neuronN
            disp(n)
%             [b, ~] = estimate_baseline_noise(neuronDf(n,:));
              b = baseline_kde(neuronDf0(n,:)')';
%             g = estimate_time_constant(neuronBase(1:1000),1);
            neuronDf(n,:) = (neuronDf0(n,:)-b)./b*100;
            base(n,:) = b;
            if reidentificationRecord(n) == 99 && ~any(isnan(neuronDf(n,:)))
                [c,s,options] = deconvolveCa(neuronDf(n,:), 'ar1', 0.95, 'method', 'constrained_foopsi');
                foopsiC(:,n) = c;
                foopsiS(:,n) = s;
            end
%             timeConstantsE(n) = -1/30/log(g);
%             timeConstantsF(n) = -1/30/log(options.pars);    
%             [c,s,options] = deconvolveCa(neuronDf(n,:), 'ar1', 0.95, 'method', 'mcmc');
%             mcmcC(:,n) = make_mean_sample(options.mcmc_results,neuronDf(n,:));
%             mcmcAPs = zeros(9000, 1);
%             for i=1:400
%                 spikeInd = ceil(options.mcmc_results.ss{i});
%                 mcmcAPs(spikeInd) = mcmcAPs(spikeInd) + options.mcmc_results.Am(i);
%             end
%             mcmcS(:,n) = mcmcAPs/sum(options.mcmc_results.Am);
    %         timeConstantsM(n,:) = sum(options.mcmc_results.g.*options.mcmc_results.Am)./sum(options.mcmc_results.Am)./30;
%             timeConstantsM(n,:) = options.mcmc_results.tau/30;
        end
        %%
        filename = sprintf('C:\\Users\\minht\\Desktop\\code\\autoCaImData\\deconv\\%sFOV%dFOOPSISingleKDE', session, FOVr);
        save(sprintf('%s.mat', filename), 'foopsiC', 'foopsiS', 'neuronDf', 'neuronN', 'neuronDf0', 'base')%, 'mcmcC', 'mcmcS', 'peelingS', 'peelingC', 'timeConstantsM', 'timeConstantsF')
        fprintf('sessionf %s FOV %d done\n', session, FOV)
    end


    %%
%     i = 1;
%     t = (1:9000)/30;
%     
%     figure
%     ax1 = subplot(3,1,1);
%     stem(t, peelingS(:,i), 'Marker', 'none')
%     title('peeling algorithm')
%     ax2 = subplot(3,1,2);
%     stem(t, foopsiS(:,i), 'Marker', 'none')
%     title('constrained foopsi')
%     ax3 = subplot(3,1,3);
%     stem(t, mcmcS(:,1), 'Marker', 'none')
%     title('MCMC')
%     xlabel('time (s)')
%     linkaxes([ax1, ax2, ax3], 'x')
%     saveas(gcf, sprintf('%sNeuron%dSpikes.png', filename, i))
%     saveas(gcf, sprintf('%sNeuron%dSpikes.fig', filename, i))
% 
%     figure
%     ax1 = subplot(3,1,1);
%     plot(t, neuronDf(i,:), 'Marker', 'none')
%     hold on
%     plot(t, peelingC(:,i), 'Marker', 'none')
%     title('peeling algorithm')
%     ax2 = subplot(3,1,2);
%     plot(t, neuronDf(i,:), 'Marker', 'none')
%     hold on
%     plot(t, foopsiC(:,i), 'Marker', 'none')
%     title(sprintf('constrained foopsi, tau=%1.3f s', timeConstantsF(i)))
%     hold off
%     ax3 = subplot(3,1,3);
%     plot(t, neuronDf(i,:), 'Marker', 'none')
%     hold on
%     plot(t, mcmcC(:,i), 'Marker', 'none')
%     title(sprintf('MCMC, tau=%1.3f s', timeConstantsM(i,2)))
%     xlabel('time (s)')
%     hold off
%     linkaxes([ax1, ax2, ax3], 'x')
%     saveas(gcf, sprintf('%sNeuron%dDeconv.png', filename, i))
%     saveas(gcf, sprintf('%sNeuron%dDeconv.fig', filename, i))
%     
%     figure
%     subplot(3,1,1)
%     histogram(timeConstantsE, 50)
%     title('estimated from first 1000 samples')
%     subplot(3,1,2)
%     histogram(timeConstantsF, 50)
%     title('constrained foopsi')
%     subplot(3,1,3)
%     histogram(timeConstantsM(:,2), 50)
%     title('MCMC')
%     saveas(gcf, sprintf('%sTauDecay.png', filename))
%     saveas(gcf, sprintf('%sTauDecay.fig', filename))
end
    