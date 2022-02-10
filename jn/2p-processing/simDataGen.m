%% setup simulation params
addedBaseline = true;
neuronN = 10;
fs = 30;
t = 5*60;
kernelAmplitude = 17;
sigma = 1:0.5:8;

x = (1:9000)';
A = 0.8;
B = 54000;
C = 0.2;

%% generate dummy simulation data dF/F + add gaussian noise
neuronDf = zeros(t*fs, neuronN);
neuronSpikes = zeros(t*fs, neuronN);
[~,~, intY, ~]=APCaModelInt_test(fs, kernelAmplitude);
neuronDfNoised = zeros(t*fs, neuronN, length(sigma));
b = A*exp(-x/B) + C;
for i = 1:neuronN
    neuronSpikes(:,i) = poissrnd(0.5/30, [9000, 1]);% + 2*poissrnd(0.05/30, [9000 1]);
    s = conv(neuronSpikes(:,i), intY);
    neuronDf(:,i) = s(31:9030);
    if addedBaseline
        neuronDf(:,i) = (neuronDf(:,i)./100).*b + b;
    end
    for si = 1:length(sigma)
        neuronDfNoised(:,i,si) = neuronDf(:,i) + sigma(si)*randn(t*fs, 1)/100*A;
    end
end

% %% add fluctuating baseline
% if addedBaseline
%     x = (1:9000)';
%     A = 0.8;
%     B = 54000;
%     C = 0.2;
%     for i = 1:neuronN
%         for si = 1:length(sigma)
%             neuronDfNoised(:,i,si) = (neuronDfNoised(:,i,si)./100).*A.*exp(-x./B)+C;
%         end
%     end
% end

% save('simulatedData.mat')

