function MultiCountDateMapFun(data,~,intermKVStore,vars,thr,group_names,subsetter,nBins,thrFnc)
% dateType: 'hour','day','dayweek','month','year'

% MultiCountMapFun(data,info,intermKVStore,varName)
% Recovers the values of variables for a given key in the first variable

parts=strsplit(vars{2},'__');
dateType=parts{end};

% The first variable is used to select for keyName
if isempty(data); warning(':S... there seems to be an empty file...'); return; end
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end

threshold = thr;
ejeHist = linspace(-1,1,nBins);

subset(strcmp(subset.(vars{1}),''),:)=[];
vals = subset.(vars{1});
groups = subset.(parts{1});
if iscell(vals) && length(threshold)==2
    vals=regexp(vals,'\d+(\.)?(\d+)?','match');
    posnan=cellfun(@(x) isempty(x),vals);
    vals(posnan)={'NaN'}; vals=str2double([vals{:}]);
end
if nargin==9 && ~isempty(thrFnc); vals=thrFnc(vals); end
if iscell(thr) || length(threshold)>2
    vals=arrayfun(@(x) {num2str(x)},vals);
    idxG1 = ismember(vals,threshold);
    idxG2 = ~ismember(vals,threshold);
elseif length(threshold)==2
    idxG1 = (vals<=min(threshold) | vals>=max(threshold));
    idxG2 = (vals> min(threshold) & vals< max(threshold));
else
    idxG1 = (cellfun(@double,vals)-48<=threshold);
    idxG2 = (cellfun(@double,vals)-48>threshold);
end

switch dateType
    case 'hour'
        groups = hour(groups);
    case 'day'
        groups = day(groups);
    case 'dayweek'
        groups = day(groups,'dayofweek');
    case 'month'
        groups = month(groups);
    case 'year'
        groups = year(groups);
end

nTypes = length(group_names);
countings = zeros(1,2*nTypes);
miHist = zeros(nTypes,length(ejeHist));
for i=1:nTypes
    countings(i) = sum( groups(:)==group_names(i) & idxG1(:) );
    countings(i+nTypes) = sum(( groups(:)==group_names(i) & idxG2(:) ));
    miHist(i,:) = myBootOdds(countings(i),sum(idxG1),...
        countings(i+nTypes),sum(idxG2),ejeHist,nBins);
end
intermKey='Null';
intermVals = {countings, miHist};
add(intermKVStore,intermKey,intermVals);

