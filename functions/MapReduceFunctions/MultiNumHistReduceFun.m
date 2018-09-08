function MultiNumHistReduceFun(~,intermValIter,outKVStore)
% MultiNumHistReduceFun(intermKey,intermValIter,outKVStore)
% Reduces and accumulates the values of variables 

ii=1;
while hasnext(intermValIter)
    aux = getnext(intermValIter);
    if ii==1; sums=aux{1};
    else
        sums = sums + aux{1};
    end
    ii=ii+1;
end
outValue = {sums};
outKey = {'sums_counts'};
addmulti(outKVStore,outKey,outValue);

end
