function BoWDiffPropsMapFun_v2(data,~,intermKVStore,vars,thr,dictionary,subsetter,thrFnc)

% UniqueCountMapFun(data,info,intermKVStore,varName)
% Maps the reading of variable varName and counting each item

% The first variable is used to select for keyName
if isempty(data); warning(':S... there seems to be an empty file...'); return; end
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end

threshold = thr; idG3=[];
docs = subset.(vars{1});
vals = subset.(vars{2});
if iscell(vals) && length(threshold)>=2
    vals=regexp(vals,'\d+(\.)?(\d+)?','match');
    posnan=cellfun(@(x) isempty(x),vals);
    vals(posnan)={'NaN'}; vals=str2double([vals{:}]);
end
if nargin==8 && ~isempty(thrFnc); vals=thrFnc(vals); end
if iscell(thr) || length(threshold)>1
    if ~iscell(vals); vals=arrayfun(@(x) {num2str(x)},vals); end
    idG1 = ismember(vals,threshold{1});
    if length(thr)>1; idG2 = ismember(vals,threshold{2});
    else; idG2 = ~ismember(vals,threshold{1});
    end
    if length(threshold)==3; idG3 = ~ismember(vals,[threshold{1}(:);threshold{2}(:)]); end
else
    %if iscell(vals); vals=str2double(vals); end
    %idG1 = (vals>=threshold);
    if iscell(vals); vals(strcmp(vals,''))={'NaN'}; vals=cellfun(@str2num,vals); end
    idG1 = (vals>=threshold);
    idG2 = (vals<threshold);
end

miniindsG1={}; miniindsG2={}; miniindsG3={}; histbagG3=[];
% aux(isnan(aux))=[]; % Se eliminan NaNs
n = length(docs);
histbagG1 = zeros(size(dictionary));
histbagG2 = histbagG1; 
if ~isempty(idG3); histbagG3 = histbagG1; end
for i=1:n
    minibag = strsplit(lower(replaceCharsbySpace(remove_accents_from_string(docs{i}))));
    minibag = regexprep(minibag,'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]*$','');
%     minibag(cellfun('length',minibag)<=1)=[]; minibag(ismember(minibag,load_stopwords))=[]; % Se quitan palabras con longitud <=1 y las stopwords
    miniinds = cellfun(@(t)find(strcmp(dictionary,t)), minibag, 'UniformOutput',false);
    if idG1(i)
        miniindsG1{i}=cat(1,miniinds{:});%unique(miniind(:));
    elseif idG2(i)
        miniindsG2{i}=cat(1,miniinds{:});%unique(miniind(:));
    else
        miniindsG3{i}=cat(1,miniinds{:});%unique(miniind(:));
    end
end
indxs=unique(cat(1,miniindsG1{:}));
counts=histc(cat(1,miniindsG1{:}),indxs);
histbagG1(indxs)=counts;
indxs=unique(cat(1,miniindsG2{:}));
counts=histc(cat(1,miniindsG2{:}),indxs);
histbagG2(indxs)=counts;
if ~isempty(idG3)
    indxs=unique(cat(1,miniindsG3{:}));
    counts=histc(cat(1,miniindsG3{:}),indxs);
    histbagG3(indxs)=counts;
end
B1 = 1000; B2=100;
deltahist = zeros(length(dictionary),B1);
diffH=deltahist; diffH2=deltahist;
if length(miniindsG1)<n; miniindsG1(end+1:n)={[]}; end
if length(miniindsG2)<n; miniindsG2(end+1:n)={[]}; end
if ~isempty(idG3) && length(miniindsG3)<n; miniindsG3(end+1:n)={[]}; end
for b=1:B1
    parfor bb = 1:B2
        ind = ceil(n*(rand(n,1)));
        ind = ind(1:100);
        miniindsG1bb=miniindsG1(ind);
        miniindsG2bb=miniindsG2(ind);
        indxs=unique(cat(1,miniindsG1bb{:}));
        counts=histc(cat(1,miniindsG1bb{:}),indxs);
        histbagG1bb=zeros(size(deltahist,1),1);
        histbagG1bb(indxs)=counts;
        histbagG1bb = histbagG1bb/sum(histbagG1bb);%sum(~isempty(histbagsevero));
        indxs=unique(cat(1,miniindsG2bb{:}));
        counts=histc(cat(1,miniindsG2bb{:}),indxs);
        histbagG2bb=zeros(size(deltahist,1),1);
        histbagG2bb(indxs)=counts;
        histbagG2bb = histbagG2bb/sum(histbagG2bb);%sum(~isempty(histbagleve));
        if ~isempty(idG3)
            miniindsG3bb=miniindsG3(ind);
            indxs=unique(cat(1,miniindsG3bb{:}));
            counts=histc(cat(1,miniindsG3bb{:}),indxs);
            histbagG3bb=zeros(size(deltahist,1),1);
            histbagG3bb(indxs)=counts;
            histbagG3bb = histbagG3bb/sum(histbagG3bb);%sum(~isempty(histbagleve));
            diffH(:,bb)=histbagG1bb-histbagG3bb;
            diffH2(:,bb)=histbagG2bb-histbagG3bb;
        else
            diffH(:,bb)=histbagG2bb-histbagG1bb;
        end
    end
    deltahist(:,b) = mean(diffH,2);
    if ~isempty(idG3)
        deltahist2(:,b) = mean(diffH2,2);
    end
end
intermKeys=dictionary;
if ~isempty(idG3); intermVals=[histbagG1,histbagG2,histbagG3,deltahist,deltahist2];
else; intermVals=[histbagG1,histbagG2,deltahist];
end
intermVals=mat2cell(intermVals,ones(size(intermVals,1),1));
addmulti(intermKVStore,intermKeys,intermVals);

