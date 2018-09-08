function kv_counts=histcountsBivariate_MR(ds,nvars,dataTypes)
% dateType: 'hour','day','dayweek','month','year'

myNames = ds.VariableNames;
ds.SelectedVariableNames = myNames(nvars);
varNames = myNames(nvars);
outdsVar = mapreduce(ds,...
    @(data,info,kvs)BivarUniqueCountMapFun(data,info,kvs,varNames,dataTypes),...
    @UniqueCountReduceFun);
kv_counts = readall(outdsVar);
ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
