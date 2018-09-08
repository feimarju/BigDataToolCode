function UniqueCountDateMapFun(data,info,intermKVStore,varName,dateType)
% dateType: 'hour','day','dayweek','month','year'

% UniqueCountMapFun(data,info,intermKVStore,varName)
% Maps the reading of variable varName and counting each item
if isempty(data); warning(':S... there seems to be an empty file...'); return; end

switch dateType
    case 'hour'
        aux = hour(data.(varName));
    case 'day'
        aux = day(data.(varName));
    case 'dayweek'
        aux = day(data.(varName),'dayofweek');
    case 'month'
        aux = month(data.(varName));
    case 'year'
        aux = year(data.(varName));
end
aux(isnan(aux))=[];
[intermKeys,~,idx] = unique(aux,'stable');
idxnan=isnan(intermKeys);
count = accumarray(idx,ones(size(idx)));
intermVals = num2cell(count);
addmulti(intermKVStore,intermKeys,intermVals);
end

function out = mycount(x)
% Counts and stores in cell format for UniqueCountMapFun
n = length(x);
out = {n}
end