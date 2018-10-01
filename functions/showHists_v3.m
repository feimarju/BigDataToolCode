function [significativas,possorted] = showHists_v3(countings_G1,countings_G2,groupNames,grouperVar,valueFilter,nbins,B,CI,nameFig,title,pathToFigs)

if nargin<6; nbins=1000; end
if nargin<7; B=1000; end

% Sumamos los conteos
if size(countings_G1,2)==1
    countings_G1 = table2array(countings_G1);
    countings_G2 = table2array(countings_G2);
    sumgrupos_G1 = sum(countings_G1);
    sumgrupos_G2 = sum(countings_G2);
else
    countings_G1 = sum(table2array(countings_G1),1);
    countings_G2 = sum(table2array(countings_G2),1);
    sumgrupos_G1 = sum(countings_G1);
    sumgrupos_G2 = sum(countings_G2);
end

%fid = fopen('BigLog.txt','a');
% Mostrar variable
%fprintf(fid,'Variable %s (filtered by %s) \n',grouperVar,valueFilter);
if ~isempty(valueFilter); fprintf('Variable %s (filtered by %s) \n',grouperVar,strjoin(valueFilter,', ')); else; fprintf('Variable %s\n',grouperVar); end
%fprintf('Variable %s (filtered by %s) \n',grouperVar,strjoin(valueFilter,', '));
ejeHist = linspace(-1,1,nbins);  % Cambiar nBins

if isnumeric(groupNames); groupNames=arrayfun(@num2cell,groupNames); end
l = length(groupNames);

%% Hists with the parallelized batch version
parfor i=1:l
    miHist(i,:) = myBootOdds2(countings_G1(i),sumgrupos_G1,...
        countings_G2(i),sumgrupos_G2,ejeHist,B);
end

%% M-mode
%figure; [significativas,possorted]=showMmode(miHist,ejeHist,groupNames,grouperVar,valueFilter,l);
%figure('Name',title,'NumberTitle','off'); [significativas,possorted]=showMmodeAndCounts(miHist,ejeHist,groupNames,grouperVar,valueFilter,countings_G1+countings_G2,CI);
hf=figure('Name',title,'NumberTitle','off'); [significativas,possorted]=showMmodeAndCounts_v2(miHist,ejeHist,groupNames,grouperVar,valueFilter,countings_G1,countings_G2,CI);

if nargin>=10 && ischar(nameFig); nameFig=strrep(matlab.lang.makeValidName(nameFig),'_',''); nameFig=matlab.lang.makeUniqueStrings(nameFig); savefig(hf,fullfile(pathToFigs,nameFig)); fprintf('Figure saved in %s\n',pathToFigs); end
