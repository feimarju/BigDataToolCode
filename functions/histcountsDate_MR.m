function kv_counts=histcountsDate_MR(ds,nvar,dateType)
% dateType: 'hour','day','dayweek','month','year'

myNames = ds.VariableNames;
ds.SelectedVariableNames = myNames{nvar};
varName = myNames{nvar};
outdsVar = mapreduce(ds,...
    @(data,info,kvs)UniqueCountDateMapFun(data,info,kvs,varName,dateType),...
    @UniqueCountReduceFun);
kv_counts = readall(outdsVar);
ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
