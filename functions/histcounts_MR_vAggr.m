function kv_counts=histcounts_MR_vAggr(ds,nvar,aggrVar,numericFilt)

myNames = ds.VariableNames;
if ~isempty(aggrVar) && ischar(aggrVar); aggrVar=find(strcmp(myNames,aggrVar)); end
varSelect = [nvar aggrVar];
ds.SelectedVariableNames = myNames(unique(varSelect));
varNames = myNames(varSelect);
% ds.SelectedVariableNames = myNames{nvar};
% varName = myNames{nvar};
outdsVar = mapreduce(ds,...
    @(data,info,kvs)UniqueCountMapFun_vAggr(data,info,kvs,varNames,numericFilt),...
    @UniqueCountReduceFun);
kv_counts = readall(outdsVar);
ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
