function SortMapFun(data,info,intermKVStore,varName,typeSort)
% typeSort: 'ascend' or 'descend'

% UniqueCountMapFun(data,info,intermKVStore,varName)
% Maps the reading of variable varName and counting each item
if isempty(data); warning(':S... there seems to be an empty file...'); return; end

aux = data.(varName);
if iscell(aux); aux(strcmp(aux,''))={'NaN'}; aux=cellfun(@str2num,aux); end
intermKeys='s';
intermVals = sort(aux,typeSort);
add(intermKVStore,intermKeys,intermVals);
end
