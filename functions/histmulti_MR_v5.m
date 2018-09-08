function [countings_G1,countings_G2,countings_G3,groupNames]=...
    histmulti_MR_v5(ds,thresholdVar,threshold,grouperVar,filteringVar,valueFilter,aggregationVar,numericFilt,thrFnc)

if nargin<9; thrFnc=[]; end
myNames = ds.VariableNames;
if ischar(thresholdVar); thresholdVar=find(strcmp(myNames,thresholdVar)); end
if ischar(grouperVar); grouperVar=find(strcmp(myNames,grouperVar)); end
if ~isempty(filteringVar) && ischar(filteringVar); filteringVar=find(strcmp(myNames,filteringVar)); end
if ~isempty(aggregationVar) && ischar(aggregationVar); aggregationVar=find(strcmp(myNames,aggregationVar)); end
varSelect = [thresholdVar grouperVar filteringVar aggregationVar];
ds.SelectedVariableNames = myNames(unique(varSelect));
varNames = myNames(varSelect);
% idxNumericVars=strcmp(ds.SelectedVariableTypes,'double');
% if ~idxNumericVars(1); error('thresholdVar has to be a numeric vector'); end
% if idxNumericVars(2); error('grouperVar has to be a string cell vector'); end
if ~isempty(filteringVar)
    %subsetter = @(data) strcmp(data.(varNames{3}),valueFilter);
    subsetter = @(data) ismember(data.(varNames{3}),valueFilter);
else; subsetter=[];
end
if ~isempty(aggregationVar); aggregationVar=varNames{end}; end

% Mapreduce
outds = mapreduce(ds,@(data,info,kvs)MultiCountMapFun_v5(data,info,kvs,...
    varNames,threshold,subsetter,aggregationVar,numericFilt,thrFnc),@MultiCountReduceFun_v2);
kv_result = readall(outds);
aux=cat(1,kv_result.Value{:}); countings_G1=aux(:,1); countings_G2=aux(:,2); if size(aux,2)==3; countings_G3=aux(:,3); else; countings_G3=[]; end
groupNames=kv_result.Key;
countings_G1=array2table(countings_G1);
countings_G2=array2table(countings_G2);
countings_G3=array2table(countings_G3);
groupNames(strcmp(groupNames,''))={'NaN'};
% for i=1:size(countings,2); if i>size(countings,2)/2; s='<'; else; s='>='; end; if i>length(groupNames); j=i-length(groupNames); else; j=i; end; variableNames{i}=sprintf('%s - %s %s %.1f',groupNames{j},varNames{1},s,threshold); end
groupNames=matlab.lang.makeValidName(groupNames);
groupNames=matlab.lang.makeUniqueStrings(groupNames);
for i=1:length(groupNames); if length(groupNames{i})>namelengthmax-3; gn=groupNames{i}(1:namelengthmax-3); else; gn=groupNames{i}; end; variableNames_G1{i}=sprintf('%s_G1',removeAccents(gn)); variableNames_G2{i}=sprintf('%s_G2',removeAccents(gn)); if ~isempty(countings_G3); variableNames_G3{i}=sprintf('%s_G3',removeAccents(gn)); end; groupNames{i}=removeAccents(groupNames{i}); end
countings_G1.Properties.RowNames=variableNames_G1;
countings_G2.Properties.RowNames=variableNames_G2;
if ~isempty(countings_G3); countings_G3.Properties.RowNames=variableNames_G3; end
%hists.Keys=groupNames;

ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
