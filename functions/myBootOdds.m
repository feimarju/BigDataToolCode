function [miHist,misdeltas, signif] = myBootOdds(cuantos1,M1,cuantos2,M2,ejeHist,B)

%

pob1 = zeros(M1,1); pob1(1:cuantos1) = 1;
pob2 = zeros(M2,1); pob2(1:cuantos2) = 1;
if nargin<6; B = 500; end
misdeltas = zeros(B,1);
for b=1:B
    ind1 = ceil(M1*rand(M1,1));
    pob1b = pob1(ind1);
    odd1 = sum(pob1b)/(M1);
    ind2 = ceil(M2*rand(M2,1));
    pob2b = pob2(ind2);
    odd2 = sum(pob2b)/(M2);
    misdeltas(b) = odd1 - odd2;
end
miHist = hist(misdeltas,ejeHist);
dataIC = miIC(misdeltas,95);
signif = (sign(dataIC(2))*sign(dataIC(3))>0);

end