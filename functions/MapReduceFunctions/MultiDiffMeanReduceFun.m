function MultiDiffMeanReduceFun(~,intermValIter,outKVStore)

% RetrieveVarsReduceFun(intermKey,intermValIter,outKVStore)
% Reduces and accumulates the values of variables 

ii=1;
while hasnext(intermValIter)
    aux = getnext(intermValIter);
    if ii==1; sums1=aux{1}; sums2=aux{2}; if length(aux)==3; sums3=aux{3}; end
    else
        sums1 = sums1 + aux{1};
        sums2 = sums2 + aux{2};
        if length(aux)==3; sums3 = sums3 + aux{3}; end
    end
    ii=ii+1;
end
if length(aux)==3; outValue = {sums1,sums2,sums3}; outKey = {'sums1','sums2','sums3'}; else; outValue = {sums1,sums2}; outKey = {'sums1', 'sums2'}; end
addmulti(outKVStore,outKey,outValue);

end
