function BoWMapFun(data,~,intermKVStore,varName)

% UniqueCountMapFun(data,info,intermKVStore,varName)
% Maps the reading of variable varName and counting each item
if isempty(data); warning(':S... there seems to be an empty file...'); return; end

aux = data.(varName);
% aux(isnan(aux))=[]; % Se eliminan NaNs
for i=1:length(aux)
    minibag = strsplit(lower(replaceCharsbySpace(remove_accents_from_string(aux{i}))));
    minibag = regexprep(minibag,'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]*$','');
    subbags{i} = minibag';
end
bag=cat(1,subbags{:});
bag(cellfun('length',bag)<=1)=[]; % Se quitan las que tengan longitud 1
bag(ismember(bag,load_stopwords))=[];
[words,~,posW]=unique(bag);
%counts = cellfun(@(t)sum(strcmp(bag,t)), words, 'UniformOutput',false);
counts = histc(posW,1:numel(words));
intermKeys=words;
intermVals=num2cell(counts);

addmulti(intermKVStore,intermKeys,intermVals);
