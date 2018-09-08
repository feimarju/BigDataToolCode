function [significativas1,possorted1,significativas2,possorted2] = showHists_v4(countings_G1,countings_G2,countings_G3,groupNames,grouperVar,valueFilter,nbins,B,CI,nameFig,title)
% El grupo 2 es el que queda en el medio, por lo tanto,
% se comparan los extremos con el medio: G1 vs. G2 y G3 vs. G2.
if nargin<6; nbins=1000; end
if nargin<7; B=1000; end

% Sumamos los conteos
countings_G1=table2array(countings_G1); countings_G2=table2array(countings_G2); if ~isempty(countings_G3); countings_G3=table2array(countings_G3); end
if ~size(countings_G1,2)==1; countings_G1=sum(countings_G1,1); countings_G2=sum(countings_G2,1); if ~isempty(countings_G3); countings_G3=sum(countings_G3,1); end; end
sumgrupos_G1=sum(countings_G1); sumgrupos_G2=sum(countings_G2); if ~isempty(countings_G3); sumgrupos_G3=sum(countings_G3); end

if ~isempty(valueFilter); fprintf('Variable %s (filtered by %s) \n',grouperVar,strjoin(valueFilter,', ')); else; fprintf('Variable %s\n',grouperVar); end
ejeHist = linspace(-1,1,nbins);  % Cambiar nBins
if isnumeric(groupNames); groupNames=arrayfun(@num2cell,groupNames); end
l = length(groupNames);

%% Hists with the parallelized batch version
parfor i=1:l
    miHist1(i,:) = myBootOdds2(countings_G1(i),sumgrupos_G1,countings_G2(i),sumgrupos_G2,ejeHist,B);
    if ~isempty(countings_G3); miHist2(i,:) = myBootOdds2(countings_G3(i),sumgrupos_G3,countings_G2(i),sumgrupos_G2,ejeHist,B); end
end

%% M-mode
hf=figure('Name',title,'NumberTitle','off');
if isempty(countings_G3)
    [significativas1,possorted1]=showMmodeAndCounts_v2(miHist1,ejeHist,groupNames,grouperVar,valueFilter,countings_G1,countings_G2,CI); significativas2=[]; possorted2=[]; 
else
    [significativas1,possorted1,significativas2,possorted2]=showMmodeAndCounts_v3(miHist1,miHist2,ejeHist,groupNames,grouperVar,valueFilter,countings_G1,countings_G2,countings_G3,CI);
end

if nargin==11 && ischar(nameFig); nameFig=strrep(matlab.lang.makeValidName(nameFig),'_',''); nameFig=matlab.lang.makeUniqueStrings(nameFig); savefig(hf,nameFig); end
