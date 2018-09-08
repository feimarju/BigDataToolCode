function [countings,histsmean,histgroups]=...
    histdiffmean_MR(ds,thresholdVar,threshold,selectedVar,filteringVar,valueFilter,numericFiltering,nBins,thrFnc)

if nargin<8; nBins=1000; end
if nargin<9; thrFnc=[]; end
myNames = ds.VariableNames;
if ischar(thresholdVar); thresholdVar=find(strcmp(myNames,thresholdVar)); end
if ischar(selectedVar); selectedVar=find(strcmp(myNames,selectedVar)); end
if ~isempty(filteringVar) && ischar(filteringVar); filteringVar=find(strcmp(myNames,filteringVar)); end
%varSelect = [numericVar thresholdVar grouperVar filteringVar];
varSelect = [thresholdVar selectedVar filteringVar];
ds.SelectedVariableNames = myNames(varSelect);
varNames = myNames(varSelect); groupNames=myNames(varSelect(2));
% idxNumericVars=strcmp(ds.SelectedVariableTypes,'double');
% if ~idxNumericVars(1); error('thresholdVar has to be a numeric vector'); end
% if idxNumericVars(2); error('grouperVar has to be a string cell vector'); end
if ~isempty(filteringVar)
    subsetter = @(data) strcmp(data.(varNames{end}),valueFilter);
else; subsetter=[];
end

% Si se pide obtener el histrograma de los dos grupos
% se ha de estimar primero un numero de bins adecuado... (min = 1000 bins)
% Para ello, se busca el minimo, el maximo, el numero de muestras totales (n) y la mediana o IQR de las
% diferencias para usar la regla de Freeman-Diaconis: h=2*IQR*n^(-1/3) y nbins=(max-min)/h.
binsGroups=[];
if nargout==3
    outds = mapreduce(ds,@(data,info,kvs)BinsMapFun(data,info,kvs,...
        varNames{2},subsetter,numericFiltering),@BinsReduceFun);
    kv_result0 = readall(outds);
    vmax=max(kv_result0.Value{2}); vmin=min(kv_result0.Value{1}); IQR=median(kv_result0.Value{3}); n=kv_result0.Value{4};
    h=2*IQR/n^(1/3); nbins=min(300,(vmax-vmin)/h); binsGroups=linspace(vmin,vmax,nbins);
end
histgroups=[];

% Mapreduce
outds = mapreduce(ds,@(data,info,kvs)MultiDiffMeanMapFun(data,info,kvs,...
    varNames,threshold,subsetter,numericFiltering,nBins,thrFnc,binsGroups),@MultiCountReduceFun);
kv_result = readall(outds);
countings = kv_result.Value{1};
countings=array2table(countings);
% for i=1:size(countings,2); if i>size(countings,2)/2; s='<'; else; s='>='; end; if i>length(groupNames); j=i-length(groupNames); else; j=i; end; variableNames{i}=sprintf('%s - %s %s %.1f',groupNames{j},varNames{1},s,threshold); end
for i=1:size(countings,2); if i>size(countings,2)/2; s='G2'; else; s='G1'; end; if i>length(groupNames); j=i-length(groupNames); else; j=i; end; variableNames{i}=sprintf('%s_%s',removeAccents(groupNames{j}),s); end
countings.Properties.VariableNames=variableNames;
for i=1:length(groupNames); groupNames{i}=removeAccents(groupNames{i}); end
histsmean = kv_result.Value{2};
histsmean = array2table(histsmean'); histsmean.Properties.VariableNames=groupNames;
histgroups.histG1=kv_result.Value{3};
histgroups.histG2=kv_result.Value{4};
histgroups.edges=binsGroups;

ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
