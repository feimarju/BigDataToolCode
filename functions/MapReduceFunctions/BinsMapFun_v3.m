function BinsMapFun_v3(data,~,intermKVStore,var,subsetter,numericFiltering,trsFnc,thrVarName,threshold,thrFnc)

% MultiCountMapFun(data,info,intermKVStore,varName)
% Recovers the values of variables for a given key in the first variable

% The first variable is used to select for keyName
if isempty(data); warning(':S... there seems to be an empty file...'); return; end
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end
if nargin>=9 && ~isempty(thrVarName) && ~isempty(threshold); isthr=true; end

vals = subset.(var); if isthr; vth = subset.(thrVarName); end; idxG3=[];
if iscell(vals)
    vals=regexp(vals,'\d+(\.)?(\d+)?','match');
    if isthr; posnan=cellfun(@(x) isempty(x),vals); vth(posnan)=[]; end
    vals=str2double([vals{:}]);
else; if isthr; vth(isnan(vals))=[]; end; vals(isnan(vals))=[];
end
if ~isempty(numericFiltering)
    if isthr; vth=vth(numericFiltering(vals)); end; vals=vals(numericFiltering(vals));
end
if nargin>=7 && ~isempty(trsFnc)
    if length(trsFnc)==2 && ~isempty(trsFnc{2}); vals(vals==0)=str2double(trsFnc{2}); end
    trsFnc{1}=str2func(trsFnc{1}); vals=trsFnc{1}(vals);
end
if isthr
    % Se obtienen los indices para cada grupo (G1 vs. G2)
    if nargin==10 && ~isempty(thrFnc); vth=thrFnc{1}(vth); end
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
end
%IQR = prctile(vals,75) - prctile(vals,25);

% Esto y toda la umbralizaci?n ("isthr=true") se hace para aprovechar la pasada del
% map-reduce de la estimaci?n de los bins para calcular las medias de los
% grupos. Con esto calculado, se puede obtener en el siguiente map-reduce
% la estimaci?n de la desviaci?n t?pica.
ivalsG1=vals(idxG1); mean1=[sum(ivalsG1(:)) length(ivalsG1)];
ivalsG2=vals(idxG2); mean2=[sum(ivalsG2(:)) length(ivalsG2)];
if ~isempty(idxG3); ivalsG3=vals(idxG3); mean3=[sum(ivalsG3(:)) length(ivalsG3)]; end

intermKey='Null';
if ~isthr; intermVals = {min(vals), max(vals), iqr(vals), length(vals)};
else; intermVals = {min(vals), max(vals), iqr(vals), length(vals), mean1, mean2}; if ~isempty(idxG3); intermVals=[intermVals,mean3]; end
end
add(intermKVStore,intermKey,intermVals);

