function BoWReduceFun(intermKey,intermValIter,outKVStore)

% UniqueCountReduceFun(intermKey,intermValIter,outKVStore
% Reduces and sums the number of instances for each element
outValue = 0;
while hasnext(intermValIter)
    values = getnext(intermValIter);
    outValue = outValue + values;
end
add(outKVStore,intermKey,outValue);

