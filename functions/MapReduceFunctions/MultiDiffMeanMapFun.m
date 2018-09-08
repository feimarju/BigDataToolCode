function MultiDiffMeanMapFun(data,~,intermKVStore,vars,thr,subsetter,numericFiltering,nBins,thrFnc,ejeBinsGroups)

% MultiCountMapFun(data,info,intermKVStore,varName)
% Recovers the values of variables for a given key in the first variable
if nargin<10; ejeBinsGroups=[]; end

% The first variable is used to select for keyName
if isempty(data); warning(':S... there seems to be an empty file...'); return; end
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end

threshold = thr;
ejeHist = linspace(-1,1,nBins);
vth = subset.(vars{1});
if nargin==9 && ~isempty(thrFnc); vth=thrFnc(vth); end
if iscell(thr) || length(threshold)>1
    idxG1 = ismember(vth,threshold);
    idxG2 = ~ismember(vth,threshold);
else
    if iscell(vth); vth(strcmp(vth,''))={'NaN'}; vth=cellfun(@str2num,vth); end
    idxG1 = (vth>=threshold);
    idxG2 = (vth<threshold);
end

vals = subset.(vars{2});
if ~isempty(numericFiltering)
    ivalsG1 = vals(idxG1 & numericFiltering(vals));
    ivalsG2 = vals(idxG2 & numericFiltering(vals));
else
    ivalsG1 = vals(idxG1);
    ivalsG2 = vals(idxG2);
end
%histG1 = zeros(1,length(ejeHist)); histG2 = histG1;
histG1 = histcounts(ivalsG1,ejeBinsGroups);
histG2 = histcounts(ivalsG2,ejeBinsGroups);

miHist = zeros(1,length(ejeHist));
countings = [nanmean(ivalsG1) nanmean(ivalsG2)];
miHist(1,:) = myBootMeans(ivalsG1,length(ivalsG1),...
    ivalsG2,length(ivalsG2),ejeHist,nBins);


intermKey='Null';
intermVals = {countings,miHist,histG1,histG2};
add(intermKVStore,intermKey,intermVals);

