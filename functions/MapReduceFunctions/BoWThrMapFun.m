function BoWThrMapFun(data,~,intermKVStore,vars,thr,subsetter)

% UniqueCountMapFun(data,info,intermKVStore,varName)
% Maps the reading of variable varName and counting each item

% The first variable is used to select for keyName
if isempty(data); warning(':S... there seems to be an empty file...'); return; end
if ~isempty(subsetter); subset = data(subsetter(data),:); else; subset=data; end

threshold = thr;
docs = subset.(vars{1});
vals = subset.(vars{2});
if iscell(vals); vals=str2double(vals); end
idG1 = (vals>=threshold);
% aux(isnan(aux))=[]; % Se eliminan NaNs
counts={};
for i=1:length(docs)
    minibag = strsplit(lower(replaceCharsbySpace(remove_accents_from_string(docs{i}))));
    subbags{i} = minibag';
    if idG1(i); isG1{i} = ones(size(minibag')); isG2{i} = zeros(size(minibag'));
    else; isG2{i} = ones(size(minibag')); isG1{i} = zeros(size(minibag'));
    end
end
bag=cat(1,subbags{:}); isG1=cat(1,isG1{:}); isG2=cat(1,isG2{:});
pos1letter=(cellfun('length',bag)<=1);
bag(pos1letter)=[]; isG1(pos1letter)=[]; isG2(pos1letter)=[];  % Se quitan las palabras con longitud <=1
posStopWords=ismember(bag,load_stopwords);
bag(posStopWords)=[]; isG1(posStopWords)=[]; isG2(posStopWords)=[]; % Se quitan las palabras que no aportan significado
words = unique(bag);
for i=1:length(words)
    posCurrentWord = strcmp(words{i},bag);
    counts{i}=[sum(posCurrentWord), sum(isG1(posCurrentWord)), sum(isG2(posCurrentWord))];
end
%counts=cellfun(@(x) [x x./(sum(cat(1,counts{:}),1)+eps)], counts,'UniformOutput',false);
intermKeys=words;
intermVals=counts;

addmulti(intermKVStore,intermKeys,intermVals);
