function UniqueCountMapFun(data,info,intermKVStore,varName)

% UniqueCountMapFun(data,info,intermKVStore,varName)
% Maps the reading of variable varName and counting each item
if isempty(data); warning(':S... there seems to be an empty file...'); return; end

aux = data.(varName);
%aux(isnan(aux))=[];
[intermKeys,~,idx] = unique(aux,'stable');
count = accumarray(idx,ones(size(idx)));
if ~iscell(intermKeys); posnans=isnan(intermKeys); intermKeys(posnans)=[]; count(posnans)=[]; end
intermVals = num2cell(count);
addmulti(intermKVStore,intermKeys,intermVals);
end

% function out = mycount(x)
% % Counts and stores in cell format for UniqueCountMapFun
% n = length(x);
% out = {n}
% end