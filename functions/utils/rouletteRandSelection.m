function x=rouletteRandSelection(bins,probs,n)
% probs=[0 0 0.2 0.4 0.3 0 0 0.6 0.8 0 0]; % probabilidades (obtenido de los conteos de un histograma) de cada bin
% bins=linspace(0,1,length(probs)); % bins
% Author: Sergio Mu?oz-Romero, 20/02/2018

if nargin<3; n=round(length(probs)/2); end % number of taken samples
ind=rand(n,1);
[~,~,ind]=histcounts(ind,[0;cumsum(probs(:))]./sum(probs)); %[~,ind]=histc(ind,[0;cumsum(probs(:))]./sum(probs));
x=bins(ind);
