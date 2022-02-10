foopsiC = zeros(9000,neuronN, length(sn));
foopsiS = zeros(9000,neuronN, length(sn));
neuronDfNb = zeros(9000,neuronN, length(sn));

for i=1:length(sn)
    parfor n=1:neuronN
        disp(n)
%         b = baseline_kde(neuronDfNoised(:,n,i));
%         neuronDfNb(:,n,i) = (neuronDfNoised(:,n,i)-b)./b*100;
        [c,s,options] = deconvolveCa(neuronDfNoised(:,n,i), 'ar1', 0.95, 'method', 'constrained_foopsi');
        foopsiC(:,n,i) = c;
        foopsiS(:,n,i) = s;
          
    end
end