function MultiCountReduceFun(~,intermValIter,outKVStore)

% RetrieveVarsReduceFun(intermKey,intermValIter,outKVStore)
% Reduces and accumulates the values of variables 

countings = [];
ii=1;
while hasnext(intermValIter)
    aux = getnext(intermValIter);
    countings = [countings; aux{1}];
    if length(aux)==2; aux{3}=[]; aux{4}=[]; end 
    if ii==1; miHist=aux{2}; histG1=aux{3}; histG2=aux{4};
    else
        miHist = miHist + aux{2};
        histG1 = histG1 + aux{3};
        histG2 = histG2 + aux{4};
    end
    ii=ii+1;
end
outValue = {countings, miHist, histG1, histG2};
outKey = {'myCountings', 'myHist', 'HistG1', 'HistG2'};
addmulti(outKVStore,outKey,outValue);

end
