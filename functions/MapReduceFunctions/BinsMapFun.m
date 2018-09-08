function BinsMapFun(data,~,intermKVStore,var,subsetter,numericFiltering,trsFnc)

% MultiCountMapFun(data,info,intermKVStore,varName)
% Recovers the values of variables for a given key in the first variable

% The first variable is used to select for keyName
if isempty(data); warning(':S... there seems to be an empty file...'); return; end
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end

vals = subset.(var);
if iscell(vals)
    vals=regexp(vals,'\d+(\.)?(\d+)?','match');
    vals=str2double([vals{:}]);
else
    vals(isnan(vals))=[];
end
if ~isempty(numericFiltering)
    vals = vals(numericFiltering(vals));
end
if nargin==7 && ~isempty(trsFnc)
    if length(trsFnc)==2 && ~isempty(trsFnc{2}); vals(vals==0)=str2double(trsFnc{2}); end
    trsFnc{1}=str2func(trsFnc{1}); vals=trsFnc{1}(vals);
end
%IQR = prctile(vals,75) - prctile(vals,25);

intermKey='Null';
intermVals = {min(vals), max(vals), iqr(vals), length(vals)};
add(intermKVStore,intermKey,intermVals);

