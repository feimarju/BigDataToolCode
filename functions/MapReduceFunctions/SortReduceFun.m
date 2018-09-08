function SortReduceFun(intermKey,intermValIter,outKVStore)

% UniqueCountReduceFun(intermKey,intermValIter,outKVStore
% Reduces and sums the number of instances for each element
outSorted = [];
typeSort='ascend';
while hasnext(intermValIter)
    values = getnext(intermValIter);
    if values(1)>=values(2); typeSort='descend'; end
    outSorted = sort([outSorted; values(:)],typeSort);
end
add(outKVStore,intermKey,outSorted);
end
