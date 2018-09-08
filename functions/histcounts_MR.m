function kv_counts=histcounts_MR(ds,nvar)

myNames = ds.VariableNames;
ds.SelectedVariableNames = myNames{nvar};
varName = myNames{nvar};
outdsVar = mapreduce(ds,...
    @(data,info,kvs)UniqueCountMapFun(data,info,kvs,varName),...
    @UniqueCountReduceFun);
kv_counts = readall(outdsVar);
ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
