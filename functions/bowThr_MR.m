function kv_result=bowThr_MR(ds,textVar,thresholdVar,threshold,filteringVar,valueFilter)

% readSize=ds.ReadSize;
% ds.ReadSize=100;
myNames = ds.VariableNames;
if ischar(textVar); textVar=find(strcmp(myNames,textVar)); end
if ischar(thresholdVar); thresholdVar=find(strcmp(myNames,thresholdVar)); end
if nargin==6 && ~isempty(filteringVar) && ischar(filteringVar); filteringVar=find(strcmp(myNames,filteringVar));
else; filteringVar=[]; end
varSelect = [textVar thresholdVar filteringVar];
ds.SelectedVariableNames = myNames(varSelect);
varNames = myNames(varSelect);
idxNumericVars=strcmp(ds.SelectedVariableTypes,'double');
if idxNumericVars(1); error('textVar has to be a string cell vector'); end
% if ~idxNumericVars(1); error('thresholdVar has to be a numeric vector'); end
if ~isempty(filteringVar)
    subsetter = @(data) strcmp(data.(varNames{3}),valueFilter);
else; subsetter=[];
end
% Mapreduce
outds = mapreduce(ds,@(data,info,kvs)BoWThrMapFun(data,info,kvs,...
    varNames,threshold,subsetter),@BoWReduceFun);
kv_result = readall(outds);
ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
% ds.ReadSize = readSize;
delete result*.mat % se eliminan los ficheros intermedios generados
