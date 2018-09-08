function significativas = showHists_v2(countings_G1,countings_G2,hists,grouperVar,valueFilter,nameFig)

if ~isstruct(hists)
    myHist=table2array(hists)';
    groupNames=hists.Properties.VariableNames;
else
    myHist=hists.Values; % Hist with the MapReduce version
    groupNames=hists.Keys;
end

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

fid = fopen('BigLog.txt','a');

% Mostrar variable
fprintf(fid,'Variable %s (nationality %s) \n',grouperVar,valueFilter);
ejeHist = linspace(-1,1,1000);  % Cambiar nBins

if isnumeric(groupNames); groupNames=arrayfun(@num2cell,groupNames); end
l = length(groupNames);
for i=1:l
    fprintf(fid,'\t Type %s',groupNames{i});
    fprintf(fid,'\t \t N1 = %d (p1 = %1.2f) vs N2 = %d (p2 = %1.2f) ',...
        countings_G1(i),countings_G1(i)/sumgrupos_G1,...
        countings_G2(i),countings_G2(i)/sumgrupos_G2);
    counts = myHist(i,:);
    empiricalCDF = cumsum(counts);
    empiricalCDF = empiricalCDF/empiricalCDF(end);
    indlow = find(empiricalCDF<=.025);
    if ~isempty(indlow); indlow = indlow(end); else indlow=1; end
    indhigh = find(empiricalCDF>.975);
    indhigh = indhigh(1);
    ic = [ejeHist(indlow), ejeHist(indhigh)];
    deltap = countings_G1(i)/sumgrupos_G1 - ...
        countings_G2(i)/sumgrupos_G2;
    if prod(ic)>0
       fprintf(fid, 'D p = %1.3f * (%1.3f,%1.3f)',...
           deltap,ic(1),ic(2));
    end
    fprintf(fid,'\n');
end

%% Hists with the parallelized batch version
parfor i=1:l
    miHist(i,:) = myBootOdds2(countings_G1(i),sumgrupos_G1,...
        countings_G2(i),sumgrupos_G2,ejeHist);
end

%% M-mode
% JL: revisar, salen bimodalidades en torno a cero que no cuadran
% figure; showMmode(myHist,ejeHist,groupNames,grouperVar,valueFilter,l,0); % Map-reduce version
figure; significativas=showMmode(miHist,ejeHist,groupNames,grouperVar,valueFilter,l); % Parallelized batch version

if nargin==6 && ischar(nameFig); savefig(nameFig); end
