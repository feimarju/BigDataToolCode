function UniqueCountMapFun_vAggr(data,~,intermKVStore,varNames,numericFilt)

% UniqueCountMapFun(data,info,intermKVStore,varName)
% Maps the reading of variable varName and counting each item
if isempty(data); warning(':S... there seems to be an empty file...'); return; end
aux = data.(varNames{1});
if length(varNames)==2
    aggr=data.(varNames{2});
    if iscell(aggr) && ~isnumeric(aggr{1}); aggr=cellfun(@(x) str2double(x),aggr); end
    if isempty(numericFilt); numericFilt=@(x) x==x; end % Deja pasar todo excepto los NaNs
    numfiltaggr=numericFilt(aggr);
    [intermKeys,~,idx] = unique(aux(numfiltaggr),'stable');
    count = accumarray(idx,aggr(numfiltaggr));
else
    [intermKeys,~,idx] = unique(aux,'stable');
    count = accumarray(idx,ones(size(idx)));
end
if ~iscell(intermKeys); posnans=isnan(intermKeys); intermKeys(posnans)=[]; count(posnans)=[]; end
intermVals = num2cell(count);
addmulti(intermKVStore,intermKeys,intermVals);
end

% function out = mycount(x)
% % Counts and stores in cell format for UniqueCountMapFun
% n = length(x);
% out = {n}
% end