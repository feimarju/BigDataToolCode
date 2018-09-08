function [countings,hists]=...
    histmulti_MR(ds,thresholdVar,threshold,grouperVar,groupNames,filteringVar,valueFilter,nBins,thrFnc)

if nargin<8; nBins=1000; end
if nargin<9; thrFnc=[]; end
myNames = ds.VariableNames;
if ischar(thresholdVar); thresholdVar=find(strcmp(myNames,thresholdVar)); end
if ischar(grouperVar); grouperVar=find(strcmp(myNames,grouperVar)); end
if ~isempty(filteringVar) && ischar(filteringVar); filteringVar=find(strcmp(myNames,filteringVar)); end
varSelect = [thresholdVar grouperVar filteringVar];
ds.SelectedVariableNames = myNames(varSelect);
varNames = myNames(varSelect);
% idxNumericVars=strcmp(ds.SelectedVariableTypes,'double');
% if ~idxNumericVars(1); error('thresholdVar has to be a numeric vector'); end
% if idxNumericVars(2); error('grouperVar has to be a string cell vector'); end
if ~isempty(filteringVar)
    subsetter = @(data) strcmp(data.(varNames{3}),valueFilter);
else; subsetter=[];
end

% Mapreduce
outds = mapreduce(ds,@(data,info,kvs)MultiCountMapFun(data,info,kvs,...
    varNames,threshold,groupNames,subsetter,nBins,thrFnc),@MultiCountReduceFun);
kv_result = readall(outds);
countings = kv_result.Value{1};
countings=array2table(countings);
groupNames(strcmp(groupNames,''))={'NaN'};
% for i=1:size(countings,2); if i>size(countings,2)/2; s='<'; else; s='>='; end; if i>length(groupNames); j=i-length(groupNames); else; j=i; end; variableNames{i}=sprintf('%s - %s %s %.1f',groupNames{j},varNames{1},s,threshold); end
groupNames=matlab.lang.makeValidName(groupNames);
groupNames=matlab.lang.makeUniqueStrings(groupNames);
for i=1:size(countings,2); if i>size(countings,2)/2; s='G2'; else; s='G1'; end; if i>length(groupNames); j=i-length(groupNames); else; j=i; end; if length(groupNames{j})>namelengthmax-3; gn=groupNames{j}(1:namelengthmax-3); else; gn=groupNames{j}; end; variableNames{i}=sprintf('%s_%s',removeAccents(gn),s); end
countings.Properties.VariableNames=variableNames;
for i=1:length(groupNames); groupNames{i}=removeAccents(groupNames{i}); end
hists = kv_result.Value{2};
hists = array2table(hists'); hists.Properties.VariableNames=groupNames;

ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
