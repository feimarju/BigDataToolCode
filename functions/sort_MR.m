function kv_sorted=sort_MR(ds,nvar,typeSort)
if nargin<3; typeSort='descend'; end

myNames = ds.VariableNames;
ds.SelectedVariableNames = myNames{nvar};
varName = myNames{nvar};
outdsVar = mapreduce(ds,...
    @(data,info,kvs)SortMapFun(data,info,kvs,varName,typeSort),...
    @SortReduceFun);
kv_sorted = readall(outdsVar);
ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
