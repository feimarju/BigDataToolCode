function MultiNumHistMapFun(data,~,intermKVStore,varname,subsetter,numericFiltering,trsFnc,ejeBinsGroups)

% MultiCountMapFun(data,info,intermKVStore,varName)
% Recovers the values of variables for a given key in the first variable
if nargin<8; ejeBinsGroups=[]; end
% The first variable is used to select for keyName
if isempty(data); warning(':S... there seems to be an empty file...'); return; end
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end
vals = subset.(varname);
% Se quitan los NaNs y se filtra por numericFiltering
vals(isnan(vals))=[];
if nargin>=6 && ~isempty(numericFiltering)
    vals=vals(numericFiltering(vals));
end
% Se transforman los datos mediante trsFnc, por ejemplo, trsFnc{1}=@log10 y trsFnc{2} se puede usar para sustituir el 0 por un valor peque?o
if nargin>=7 && ~isempty(trsFnc)
    if ~isempty(trsFnc{2}); vals(vals==0)=str2double(trsFnc{2}); end
    trsFnc{1}=str2func(trsFnc{1}); vals=trsFnc{1}(vals);
end
[counts,~,bins]=histcounts(vals,ejeBinsGroups);
st=zeros(length(counts),2);
for j=1:length(counts)
    xxx=vals(bins==j); st(j,:)=[sum(xxx) counts(j)];
end
intermKey='Null';
intermVals = {st};
add(intermKVStore,intermKey,intermVals);

