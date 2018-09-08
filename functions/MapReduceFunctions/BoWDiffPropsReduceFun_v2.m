function BoWDiffPropsReduceFun_v2(intermKey,intermValIter,outKVStore)

% UniqueCountReduceFun(intermKey,intermValIter,outKVStore
% Reduces and sums the number of instances for each element
histbagG1=0; histbagG2=0; histbagG3=0; deltahist=[]; deltahist2=[]; 
while hasnext(intermValIter)
    values = getnext(intermValIter);
    histbagG1 = histbagG1 + values(:,1);
    histbagG2 = histbagG2 + values(:,2);
    if length(values)==3+2000 %(B=1000 para deltahist1 y deltahist2)
        histbagG3 = histbagG3 + values(:,3);
        deltahist = [deltahist values(:,4:length(4:end)/2)];
        deltahist2 = [deltahist2 values(:,length(4:end)/2+1:end)];
    elseif length(values)==2+1000; deltahist = [deltahist values(:,3:end)];
    else; error('Check parameter B of map function...');
    end
end
if isempty(deltahist2)
    add(outKVStore,intermKey,{histbagG1,histbagG2,deltahist});
else
    add(outKVStore,intermKey,{histbagG1,histbagG2,histbagG3,deltahist,deltahist2});
end

