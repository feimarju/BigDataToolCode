function [miHist,misdeltas, signif] = myBootMeans(vals1,M1,vals2,M2,ejeHist,B)

%

l1=length(vals1); % Si hay nans... aqui se estan teniendo en cuenta...
l2=length(vals2);
if nargin<6; B = 500; end
misdeltas = zeros(B,1);
for b=1:B
    ind1 = ceil(l1*rand(l1,1));
    pob1b = vals1(ind1);
    odd1 = nansum(pob1b)/(M1);
    ind2 = ceil(l2*rand(l2,1));
    pob2b = vals2(ind2);
    odd2 = nansum(pob2b)/(M2);
    misdeltas(b) = odd1 - odd2;
end
miHist = hist(misdeltas,ejeHist);
dataIC = miIC(misdeltas,95);
signif = (sign(dataIC(2))*sign(dataIC(3))>0);

end