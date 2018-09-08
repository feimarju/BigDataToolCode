function MultiCountMapFun_v4(data,~,intermKVStore,vars,thr,subsetter,nBins,thrFnc)

% MultiCountMapFun_v2(data,info,intermKVStore,vars,thr,subsetter,nBins,thrFnc)
% Recovers the values of variables for a given key in the first variable

if isempty(data); warning(':S... there seems to be an empty file...'); return; end
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end

threshold = thr; idxG3=[];
vals = subset.(vars{1});
if iscell(vals) && length(threshold)>=2
    vals=regexp(vals,'\d+(\.)?(\d+)?','match');
    posnan=cellfun(@(x) isempty(x),vals);
    vals(posnan)={'NaN'}; vals=str2double([vals{:}]);
end
if nargin==9 && ~isempty(thrFnc); vals=thrFnc(vals); end
if iscell(thr) || length(threshold)>1
    if ~iscell(vals); vals=arrayfun(@(x) {num2str(x)},vals); end
    idxG1 = ismember(vals,threshold{1});
    if length(thr)>1; idxG2 = ismember(vals,threshold{2});
    else; idxG2 = ~ismember(vals,threshold{1});
    end
    if length(threshold)==3; idxG3 = ~ismember(vals,[threshold{1}(:);threshold{2}(:)]); end
else
    if iscell(vals); vals(strcmp(vals,''))={'NaN'}; vals=cellfun(@str2num,vals); end
    idxG1 = (vals>=threshold);
    idxG2 = (vals<threshold);
end

groups = subset.(vars{2});
group_names=unique(groups);
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

