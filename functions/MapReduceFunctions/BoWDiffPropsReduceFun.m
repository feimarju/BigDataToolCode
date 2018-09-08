function BoWDiffPropsReduceFun(intermKey,intermValIter,outKVStore)

% UniqueCountReduceFun(intermKey,intermValIter,outKVStore
% Reduces and sums the number of instances for each element
histbagG1=0; histbagG2=0; deltahist=[]; 
while hasnext(intermValIter)
    values = getnext(intermValIter);
    histbagG1 = histbagG1 + values(1);
    histbagG2 = histbagG2 + values(2);
    deltahist = [deltahist values(3:end)];
end
add(outKVStore,intermKey,{histbagG1,histbagG2,deltahist});

