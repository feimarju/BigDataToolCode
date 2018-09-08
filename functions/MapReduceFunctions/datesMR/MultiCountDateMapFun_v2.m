function MultiCountDateMapFun_v2(data,~,intermKVStore,vars,thr,group_names,subsetter,nBins,thrFnc)
% dateType: 'hour','day','dayweek','month','year'

% MultiCountMapFun(data,info,intermKVStore,varName)
% Recovers the values of variables for a given key in the first variable
if isempty(data); warning(':S... there seems to be an empty file...'); return; end

parts=strsplit(vars{2},'__');
dateType=parts{end};

% The first variable is used to select for keyName
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end

threshold = thr; idxG3=[];
subset(strcmp(subset.(vars{1}),''),:)=[];
vals = subset.(vars{1});
groups = subset.(parts{1});
if iscell(vals) && length(threshold)>=2
    vals=regexp(vals,'\d+(\.)?(\d+)?','match');
    posnan=cellfun(@(x) isempty(x),vals);
    vals(posnan)={'NaN'}; vals=str2double([vals{:}]);
end
if iscell(vals)
    if sum(cell2mat(cellfun(@isnan,vals,'UniformOutput',false)'))>length(vals)/2; vals = subset.(vars{1}); end
else
    if sum(isnan(vals))>length(vals)/2; vals = subset.(vars{1}); end
end
if nargin==9 && ~isempty(thrFnc); vals=thrFnc(vals); end
if iscell(thr) || length(threshold)>2
    if ~iscell(vals); vals=arrayfun(@(x) {num2str(x)},vals); end
    idxG1 = ismember(vals,threshold{1});
    if length(thr)>1; idxG2 = ismember(vals,threshold{2});
    else; idxG2 = ~ismember(vals,threshold{1});
    end
    if length(threshold)==3; idxG3 = ~ismember(vals,[threshold{1}(:);threshold{2}(:)]); end
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
values=cell(1,nTypes);
g=cell(length(groups),1); if ~iscell(groups); for i=1:length(g); g{i}=num2str(groups(i)); end; groups=g; end
g=cell(nTypes,1); if ~iscell(group_names); for i=1:length(g); g{i}=num2str(group_names(i)); end; group_names=g; end
for i=1:nTypes
    countings_G1 = sum(( strcmp(groups(:),group_names{i}) & idxG1(:) ));
    countings_G2 = sum(( strcmp(groups(:),group_names{i}) & idxG2(:) ));
    values{i}=[countings_G1 countings_G2];
    if ~isempty(idxG3)
        countings_G3 = sum(( strcmp(groups(:),group_names{i}) & idxG3(:) ));
        values{i}=[values{i} countings_G3];
    end
end
intermKey = group_names;
intermVals = values;
addmulti(intermKVStore,intermKey,intermVals);

