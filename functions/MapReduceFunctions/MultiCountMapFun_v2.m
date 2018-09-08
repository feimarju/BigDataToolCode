function MultiCountMapFun_v2(data,~,intermKVStore,vars,thr,subsetter,nBins,thrFnc)

% MultiCountMapFun_v2(data,info,intermKVStore,vars,thr,subsetter,nBins,thrFnc)
% Recovers the values of variables for a given key in the first variable

if isempty(data); warning(':S... there seems to be an empty file...'); return; end
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end

threshold = thr;
ejeHist = linspace(-1,1,nBins);
vals = subset.(vars{1});
if nargin==9 && ~isempty(thrFnc); vals=thrFnc(vals); end
if iscell(thr) || length(threshold)>1
    idxG1 = ismember(vals,threshold);
    idxG2 = ~ismember(vals,threshold);
else
    if iscell(vals); vals(strcmp(vals,''))={'NaN'}; vals=cellfun(@str2num,vals); end
    idxG1 = (vals>=threshold);
    idxG2 = (vals<threshold);
end

groups = subset.(vars{2});
group_names=unique(groups);
nTypes = length(group_names);
values=cell(1,nTypes); countings = zeros(1,2*nTypes); miHist = zeros(nTypes,length(ejeHist));
g=cell(length(groups),1); if ~iscell(groups); for i=1:length(g); g{i}=num2str(groups(i)); end; groups=g; end;
g=cell(nTypes,1); if ~iscell(group_names); for i=1:length(g); g{i}=num2str(group_names(i)); end; group_names=g; end;
for i=1:nTypes
    countings_G1 = sum(( strcmp(groups,group_names{i}) & idxG1 ));
    countings_G2 = sum(( strcmp(groups,group_names{i}) & idxG2 ));
    miHist = myBootOdds(countings(i),sum(idxG1),...
        countings(i+nTypes),sum(idxG2),ejeHist,nBins);
    values{i}=[countings_G1 countings_G2 miHist(:)'];
end
intermKey = group_names;
intermVals = values;
addmulti(intermKVStore,intermKey,intermVals);

