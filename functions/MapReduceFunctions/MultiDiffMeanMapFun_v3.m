function MultiDiffMeanMapFun_v3(data,~,intermKVStore,vars,threshold,subsetter,numericFiltering,thrFnc,trsFnc,ejeBinsGroups,means)

% MultiCountMapFun(data,info,intermKVStore,varName)
% Recovers the values of variables for a given key in the first variable
if nargin<10; ejeBinsGroups=[]; end
if nargin<11; means=[0 0 0]; end

% The first variable is used to select for keyName
if isempty(data); warning(':S... there seems to be an empty file...'); return; end
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end

vth = subset.(vars{1}); vals = subset.(vars{2}); idxG3=[];
% Se quitan los NaNs y se filtra por numericFiltering
if iscell(vals)
    vals=regexp(vals,'\d+(\.)?(\d+)?','match');
    posnan=cellfun(@(x) isempty(x),vals);
    vals=str2double([vals{:}]); vth(posnan)=[];
else; vth(isnan(vals))=[]; vals(isnan(vals))=[];
end
if iscell(vth) && length(threshold)==2
    vth=regexp(vth,'\d+(\.)?(\d+)?','match');
    posnan=cellfun(@(x) isempty(x),vth);
    vth(posnan)={'NaN'}; vth=str2double([vth{:}]);
end
% Se aplica el filtrado especificado en el campo "Numeric Filtering"
if nargin>=6 && ~isempty(numericFiltering)
    vth=vth(numericFiltering(vals)); vals=vals(numericFiltering(vals));
end
% Se obtienen los indices para cada grupo (G1 vs. G2)
if nargin==8 && ~isempty(thrFnc); vth=thrFnc(vth); end
if iscell(threshold) || length(threshold)>2
    if ~iscell(vth); vth=arrayfun(@(x) {num2str(x)},vth); end
    idxG1 = ismember(vth,threshold{1});
    if length(threshold)>1; idxG2 = ismember(vth,threshold{2}); else; idxG2 = ~ismember(vth,threshold{1}); end
    if length(threshold)==3; idxG3 = ~ismember(vth,[threshold{1}(:);threshold{2}(:)]); end
elseif length(threshold)==2
    idxG1 = (vth<=min(threshold) | vth>=max(threshold));
    idxG2 = (vth> min(threshold) & vth< max(threshold));
else
    if iscell(vth); vth(strcmp(vth,''))={'NaN'}; vth=cellfun(@str2num,vth); end
    idxG1 = (vth<=threshold);
    idxG2 = (vth>threshold);
end
% Se transforman los datos mediante trsFnc, por ejemplo, trsFnc{1}=@log10 y trsFnc{2} se puede usar para sustituir el 0 por un valor peque?o
if nargin>=9 && ~isempty(trsFnc)
    if length(trsFnc)==2 && ~isempty(trsFnc{2}); vals(vals==0)=str2double(trsFnc{2}); end
    trsFnc{1}=str2func(trsFnc{1}); vals=trsFnc{1}(vals);
end

ivalsG1 = vals(idxG1); ivalsG2 = vals(idxG2);
[counts1,~,bins1]=histcounts(ivalsG1,ejeBinsGroups);
[counts2,~,bins2]=histcounts(ivalsG2,ejeBinsGroups);
st1=zeros(length(counts1),3); st2=st1;
if ~isempty(idxG3); ivalsG3 = vals(idxG3); [counts3,~,bins3]=histcounts(ivalsG3,ejeBinsGroups); st3=st1; end
for j=1:length(counts1)
    xxx=ivalsG1(bins1==j); st1(j,:)=[sum(xxx) counts1(j) sum((xxx-means(1)).^2)];
    xxx=ivalsG2(bins2==j); st2(j,:)=[sum(xxx) counts2(j) sum((xxx-means(2)).^2)];
    if ~isempty(idxG3); xxx=ivalsG3(bins3==j); st3(j,:)=[sum(xxx) counts3(j) sum((xxx-means(3)).^2)]; end
end

intermKey='Null';
if ~isempty(idxG3); intermVals = {st1,st2,st3}; else; intermVals = {st1,st2}; end
add(intermKVStore,intermKey,intermVals);

