function kv_counts=bow_MR(ds,textVar)

myNames = ds.VariableNames;
if ischar(textVar); textVar=find(strcmp(myNames,textVar)); end
ds.SelectedVariableNames = myNames{textVar};
varName = myNames{textVar};
outdsVar = mapreduce(ds,...
    @(data,info,kvs)BoWMapFun(data,info,kvs,varName),...
    @BoWReduceFun);
kv_counts = readall(outdsVar);
ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result*.mat % se eliminan los ficheros intermedios generados
