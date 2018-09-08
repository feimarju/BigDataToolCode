function BivarUniqueCountMapFun(data,info,intermKVStore,varNames,dataTypes)
% dateType: 'hour','day','dayweek','month','year'

% UniqueCountMapFun(data,info,intermKVStore,varName)
% Maps the reading of variable varName and counting each item
if isempty(data); warning(':S... there seems to be an empty file...'); return; end

for iv=1:length(dataTypes)
    switch dataTypes{iv}
        case 'Cat'
            auxs{iv} = data.(varNames{iv});
        case 'Num'
            auxs{iv} = data.(varNames{iv});
        case 'hour'
            auxs{iv} = hour(data.(varNames{iv}));
        case 'day'
            auxs{iv} = day(data.(varNames{iv}));
        case 'dayweek'
            auxs{iv} = day(data.(varNames{iv}),'dayofweek');
        case 'month'
            auxs{iv} = month(data.(varNames{iv}));
        case 'year'
            auxs{iv} = year(data.(varNames{iv}));
    end
    %aux(isnan(aux))=[];
end
if iscell(auxs{1}) && iscell(auxs{2})
    joinauxs=@(x,y) sprintf('%s_%s',x,y);
    aux=cellfun(joinauxs,auxs{1},auxs{2},'UniformOutput',false); clear auxs;
elseif ~iscell(auxs{1}) && iscell(auxs{2})
    joinauxs=@(x,y) sprintf('%d_%s',x,y);
    aux=cellfun(joinauxs,num2cell(auxs{1}),auxs{2},'UniformOutput',false); clear auxs;
elseif iscell(auxs{1}) && ~iscell(auxs{2})
    joinauxs=@(x,y) sprintf('%s_%d',x,y);
    aux=cellfun(joinauxs,auxs{1},num2cell(auxs{2}),'UniformOutput',false); clear auxs;
end
[intermKeys,~,idx] = unique(aux,'stable');
%idxnan=isnan(intermKeys);
count = accumarray(idx,ones(size(idx)));
intermVals = num2cell(count);
addmulti(intermKVStore,intermKeys,intermVals);
end

% function out = mycount(x)
% % Counts and stores in cell format for UniqueCountMapFun
% n = length(x);
% out = {n}
% end