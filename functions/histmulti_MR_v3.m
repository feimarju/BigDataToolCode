function [countings_G1,countings_G2,groupNames]=...
    histmulti_MR_v3(ds,thresholdVar,threshold,grouperVar,filteringVar,valueFilter,nBins,thrFnc)

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
outds = mapreduce(ds,@(data,info,kvs)MultiCountMapFun_v3(data,info,kvs,...
    varNames,threshold,subsetter,nBins,thrFnc),@MultiCountReduceFun_v2);
kv_result = readall(outds);
aux=cat(1,kv_result.Value{:}); countings_G1=aux(:,1); countings_G2=aux(:,2); %hists.Values=aux(:,3:end);
groupNames=kv_result.Key;
countings_G1=array2table(countings_G1);
countings_G2=array2table(countings_G2);
groupNames(strcmp(groupNames,''))={'NaN'};
% for i=1:size(countings,2); if i>size(countings,2)/2; s='<'; else; s='>='; end; if i>length(groupNames); j=i-length(groupNames); else; j=i; end; variableNames{i}=sprintf('%s - %s %s %.1f',groupNames{j},varNames{1},s,threshold); end
groupNames=matlab.lang.makeValidName(groupNames);
groupNames=matlab.lang.makeUniqueStrings(groupNames);
for i=1:length(groupNames); if length(groupNames{i})>namelengthmax-3; gn=groupNames{i}(1:namelengthmax-3); else; gn=groupNames{i}; end; variableNames_G1{i}=sprintf('%s_G1',removeAccents(gn)); variableNames_G2{i}=sprintf('%s_G2',removeAccents(gn)); groupNames{i}=removeAccents(groupNames{i}); end
countings_G1.Properties.RowNames=variableNames_G1;
countings_G2.Properties.RowNames=variableNames_G2;
%hists.Keys=groupNames;

ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
