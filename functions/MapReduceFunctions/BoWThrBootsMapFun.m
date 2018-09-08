function BoWThrBootsMapFun(data,~,intermKVStore,vars,thr,subsetter)

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
    minibag(cellfun('length',minibag)<=1)=[]; minibag(ismember(minibag,load_stopwords))=[]; % Se quitan palabras con longitud <=1 y las stopwords
    subbags{i} = minibag';
    if idG1(i); isG1{i} = ones(size(minibag')); isG2{i} = zeros(size(minibag'));
    else; isG2{i} = ones(size(minibag')); isG1{i} = zeros(size(minibag'));
    end
end
bag=cat(1,subbags{:}); %isG1=cat(1,isG1{:}); isG2=cat(1,isG2{:});
words = unique(bag);
keyboard
for j=1:100
    ind=randi(length(docs),[1,10]); % Submuestreo con reemplazamiento
    subbagsj=subbags(ind); isG1j=isG1(ind); isG2j=isG2(ind);
    bagj=cat(1,subbagsj{:}); isG1j=cat(1,isG1j{:}); isG2j=cat(1,isG2j{:});
    wordsj = unique(bagj);
    for i=1:length(words)
        if j==1; numwordinbag(i)=sum(strcmp(words{i},bag)); end
        posCurrentWord = strcmp(words{i},bagj);
        counts{i}(j,:)=[numwordinbag(i), sum(isG1j(posCurrentWord)), sum(isG2j(posCurrentWord))]; %counts{i}(j,:)=[numwordinbag(i), sum(posCurrentWord), sum(isG1j(posCurrentWord)), sum(isG2j(posCurrentWord))];
    end
end
% Se incluye el vector con la diferencia de los porcentajes de aparci?n de cada grupo (G1-G2) para cada palabra
denom=(sum(cat(3,counts{:}),3)+eps); 
counts=cellfun(@(x) [x diff(counts{1}(:,3:-1:2)./denom(:,3:-1:2),1,2)], counts,'UniformOutput',false);
intermKeys=words;
intermVals=counts;

addmulti(intermKVStore,intermKeys,intermVals);
