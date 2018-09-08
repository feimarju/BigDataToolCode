function MultiCountReduceFun_v2(intermKey,intermValIter,outKVStore)

% Reduces and accumulates the values of variables 
outValue = 0;
while hasnext(intermValIter)
    values = getnext(intermValIter);
    outValue = outValue + values;
end
add(outKVStore,intermKey,outValue);

end
