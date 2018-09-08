function significativas = showHists(countings,hists,groupNames,grouperVar,valueFilter,nameFig)

myHist=table2array(hists)'; % Hist with the MapReduce version

% Sumamos los conteos
myCountingsAll = sum(table2array(countings),1);
sumgrupos = [sum(myCountingsAll(1:end/2)) sum(myCountingsAll(end/2+1:end))];

fid = fopen('BigLog.txt','a');

% Mostrar variable
fprintf(fid,'Variable %s (nationality %s) \n',grouperVar,valueFilter);
ejeHist = linspace(-1,1,1000);  % Cambiar nBins

if isnumeric(groupNames); groupNames=arrayfun(@num2cell,groupNames); end
l = length(groupNames);
for i=1:l
    fprintf(fid,'\t Type %s',groupNames{i});
    fprintf(fid,'\t \t N1 = %d (p1 = %1.2f) vs N2 = %d (p2 = %1.2f) ',...
        myCountingsAll(i),myCountingsAll(i)/sumgrupos(1),...
        myCountingsAll(i+l),myCountingsAll(i+l)/sumgrupos(2));
    counts = myHist(i,:);
    empiricalCDF = cumsum(counts);
    empiricalCDF = empiricalCDF/empiricalCDF(end);
    indlow = find(empiricalCDF<=.025);
    if ~isempty(indlow); indlow = indlow(end); else indlow=1; end
    indhigh = find(empiricalCDF>.975);
    indhigh = indhigh(1);
    ic = [ejeHist(indlow), ejeHist(indhigh)];
    deltap = myCountingsAll(i)/sumgrupos(1) - ...
        myCountingsAll(i+l)/sumgrupos(2);
    if prod(ic)>0
       fprintf(fid, 'D p = %1.3f * (%1.3f,%1.3f)',...
           deltap,ic(1),ic(2));
    end
    fprintf(fid,'\n');
end

%% Hists with the parallelized batch version
parfor i=1:l
    miHist(i,:) = myBootOdds2(myCountingsAll(i),sumgrupos(1),...
        myCountingsAll(i+l),sumgrupos(2),ejeHist);
end

%% M-mode
% JL: revisar, salen bimodalidades en torno a cero que no cuadran
figure; showMmode(myHist,ejeHist,groupNames,grouperVar,valueFilter,l,0); % Map-reduce version
figure; significativas=showMmode(miHist,ejeHist,groupNames,grouperVar,valueFilter,l,1); % Parallelized batch version
% figure
% subplot(1,2,1); showMmode(myHist,ejeHist,groupNames,grouperVar,valueFilter,l,0); % Map-reduce version
% subplot(1,2,2); significativas=showMmode(miHist,ejeHist,groupNames,grouperVar,valueFilter,l,1); % Parallelized batch version

if nargin==6 && ischar(nameFig); savefig(nameFig); end
