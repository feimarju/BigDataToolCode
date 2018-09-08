function BinsReduceFun(~,intermValIter,outKVStore)

% RetrieveVarsReduceFun(intermKey,intermValIter,outKVStore)
% Reduces and accumulates the values of variables 

IQRs = []; mins=[]; maxs=[]; n=0; meanG1=[0 0]; meanG2=[0 0]; meanG3=[0 0];
while hasnext(intermValIter)
    aux = getnext(intermValIter);
    mins = [mins aux{1}];
    maxs = [maxs aux{2}];
    IQRs = [IQRs aux{3}];
    n = n + aux{4};
    if length(aux)>4; meanG1=meanG1+aux{5}; meanG2=meanG2+aux{6}; if length(aux)==7; meanG3=meanG3+aux{7}; end
end
if sum(meanG1)==0; outValue = {mins,maxs,IQRs,n}; outKey = {'Mins','Maxs','IQRs','n'};
else; outValue = {mins,maxs,IQRs,n,meanG1,meanG2}; outKey = {'Mins','Maxs','IQRs','n','meanG1','meanG2'}; if length(aux)==7; outValue=[outValue,meanG3]; outKey=[outKey,'meanG3']; end
end
addmulti(outKVStore,outKey,outValue);

end
