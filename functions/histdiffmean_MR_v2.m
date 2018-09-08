function [countings,significativas]=...
    histdiffmean_MR_v2(ds,thresholdVar,threshold,selectedVar,filteringVar,valueFilter,numericFiltering,nBins,thrFnc,trsFnc,CI)

if nargin<8; nBins=1000; end
if nargin<9; thrFnc=[]; end
if iscell(threshold) && ischar(threshold{1}); threshold=strrep(threshold,'NaN',''); end % Cuando se muestran las keys en la umbralizaci?n, se cambian las keys='' a keys='NaN'. Aqu? se deshace ese cambio.
myNames = ds.VariableNames;
if ischar(thresholdVar); thresholdVar=find(strcmp(myNames,thresholdVar)); end
if ischar(selectedVar); selectedVar=find(strcmp(myNames,selectedVar)); end
if ~isempty(filteringVar) && ischar(filteringVar); filteringVar=find(strcmp(myNames,filteringVar)); end
%varSelect = [numericVar thresholdVar grouperVar filteringVar];
varSelect = [thresholdVar selectedVar filteringVar];
ds.SelectedVariableNames = myNames(unique(varSelect));
varNames = myNames(varSelect); groupNames=myNames(varSelect(2));
% idxNumericVars=strcmp(ds.SelectedVariableTypes,'double');
% if ~idxNumericVars(1); error('thresholdVar has to be a numeric vector'); end
% if idxNumericVars(2); error('grouperVar has to be a string cell vector'); end
if ~isempty(filteringVar)
    %subsetter = @(data) strcmp(data.(varNames{end}),valueFilter);
    subsetter = @(data) ismember(data.(varNames{end}),valueFilter);
else; subsetter=[];
end

% Si se pide obtener el histrograma de los dos grupos
% se ha de estimar primero un numero de bins adecuado... (min = 1000 bins)
% Para ello, se busca el minimo, el maximo, el numero de muestras totales (n) y la mediana o IQR de las
% diferencias para usar la regla de Freeman-Diaconis: h=2*IQR*n^(-1/3) y nbins=(max-min)/h.
outds = mapreduce(ds,@(data,info,kvs)BinsMapFun_v3(data,info,kvs,...
    varNames{2},subsetter,numericFiltering,trsFnc,varNames{1},threshold,thrFnc),@BinsReduceFun);
kv_result0 = readall(outds);
vmax=max(kv_result0.Value{2}); vmin=min(kv_result0.Value{1}); IQR=median(kv_result0.Value{3}); n=kv_result0.Value{4};
means(1)=kv_result0.Value{5}(1)/kv_result0.Value{5}(2); means(2)=kv_result0.Value{6}(1)/kv_result0.Value{6}(2);
if length(threshold)>2; means(3)=kv_result0.Value{7}(1)/kv_result0.Value{7}(2); end
h=2*IQR/n^(1/3); nbins=min(nBins,(vmax-vmin)/h); binsGroups=linspace(vmin,vmax,nbins);
% Mapreduce
outds = mapreduce(ds,@(data,info,kvs)MultiDiffMeanMapFun_v3(data,info,kvs,...
    varNames,threshold,subsetter,numericFiltering,thrFnc,trsFnc,binsGroups,means),@MultiDiffMeanReduceFun);
kv_result = readall(outds);
sums1 = kv_result.Value{1}; sums2 = kv_result.Value{2};
n1=sum(sums1(:,2)); n2=sum(sums2(:,2)); m3=false;
probs1=sums1(:,2)/n1; means1=sums1(:,1)./sums1(:,2); posNaNs1=isnan(means1); probs1(posNaNs1)=[]; means1(posNaNs1)=[];
probs2=sums2(:,2)/n2; means2=sums2(:,1)./sums2(:,2); posNaNs2=isnan(means2); probs2(posNaNs2)=[]; means2(posNaNs2)=[];
if length(threshold)>2; m3=true; sums3 = kv_result.Value{3}; n3=sum(sums3(:,2)); probs3=sums3(:,2)/n3; means3=sums3(:,1)./sums3(:,2); posNaNs3=isnan(means3); probs3(posNaNs3)=[]; means3(posNaNs3)=[]; end

B=1000;
if ~m3 % Si no se compara con tres grupos distintos (dos umbrales: Top,Normal,Small)
    parfor b=1:B
        logx1b=rouletteRandSelection(means1,probs1,n1);
        logx2b=rouletteRandSelection(means2,probs2,n2);
        dm1b(b) = mean(logx1b)-mean(logx2b);
        ds1b(b) = std(logx1b) - std(logx2b);
        hist1b(b,:) = histcounts(logx1b,binsGroups);
        hist2b(b,:) = histcounts(logx2b,binsGroups);
        dhistb(b,:) = hist1b(b,:) - hist2b(b,:);
    end
    % Representaciones
    hh1 = mean(hist1b(:,~posNaNs1),1); hh1T = hh1/(sum(mean(hist1b,1))+sum(mean(hist2b,1))); hh1 = hh1/sum(hh1);
    hh2 = mean(hist2b(:,~posNaNs2),1); hh2T = hh2/(sum(mean(hist2b,1))+sum(mean(hist1b,1))); hh2 = hh2/sum(hh2);
    normdhistb=dhistb/(sum(mean(hist1b,1))+sum(mean(hist2b,1)));
    nameVar=strrep(varNames{2},'_',' '); if ~isempty(trsFnc); nameVar=sprintf('%s(%s)',trsFnc{1}(2:end),nameVar); end
    figure; title([nameVar, ' ', valueFilter]);
    subplot(3,2,1); plot(means1,hh1); hold on; plot(means2,hh2); xlabel(nameVar); ylabel('pdf','Interpreter','Latex'); axis tight; legend('G1','G2'); set(gca,'FontSize',16,'FontName','Times'); yl=ylim;
    subplot(3,2,3); plot(means1,hh1T); hold on; plot(means2,hh2T); xlabel(nameVar); ylabel('normalized pdf','Interpreter','Latex'); axis tight; legend('G1','G2'); set(gca,'FontSize',16,'FontName','Times'); ylim(yl);
    subplot(3,2,5); pintaICgris(normdhistb,[],CI,binsGroups(1:end-1)); xlabel(nameVar); ylabel('$\Delta$ pdf','Interpreter','Latex'); axis tight; set(gca,'FontSize',16,'FontName','Times'); yl=ylim; if abs(yl(1)/yl(2))<.1; yl(1)=-max(abs(yl(1)),abs(.2*yl(2))); elseif abs(yl(2)/yl(1))<.1; yl(2)=max(abs(yl(2)),abs(.2*yl(1))); end; ylim(yl);
    subplot(3,2,[2 4 6]); histogram(dm1b,50,'Normalization','pdf'); hold on; histogram(ds1b,50,'Normalization','pdf'); hl=legend('$\Delta mean$','$\Delta std$'); set(hl,'Interpreter','Latex'); xlabel(nameVar,'Interpreter','Latex'); ylabel('pdf','Interpreter','Latex'); axis tight; set(gca,'FontSize',16,'FontName','Times')
    if sign(max(dm1b))==sign(min(dm1b)) && sign(max(ds1b))==sign(min(ds1b)); xl=xlim; if sign(max(dm1b))>0; xl(1)=-.1*xl(2); else; xl(2)=-.1*xl(1); end; xlim(xl); end
    yl=ylim; plot(zeros(1,2),[0 yl(2)],'Linewidth',1.2,'Color',[237,185,49]/255);%[248,215,74]/255);
    % Diferencia de media y std para los cromosomas
    diffMean=sum(sums1(:,1))/n1 - sum(sums2(:,1))/n2;
    diffStd=sqrt(sum(sums1(:,3))/(n1-1)) - sqrt(sum(sums2(:,3))/(n2-1));
    countings = [diffMean diffStd];
    % Se determina si son significativas
    dataIC = miIC([dm1b(:),ds1b(:)],CI);
    indSelect = find((sign(dataIC(2,:))==sign(dataIC(3,:))) & not(sign(dataIC(2,:))==0));
    significativas=false(1,2); significativas(indSelect)=true;
else % Si se compara con tres grupos distintos (dos umbrales: Top,Normal,Small)
    parfor b=1:B
        logx1b=rouletteRandSelection(means1,probs1,n1);
        logx2b=rouletteRandSelection(means2,probs2,n2);
        logx3b=rouletteRandSelection(means3,probs3,n3);
        dm1b(b) = mean(logx1b)-mean(logx3b); ds1b(b) = std(logx1b) - std(logx3b);
        dm2b(b) = mean(logx2b)-mean(logx3b); ds2b(b) = std(logx2b) - std(logx3b);
        hist1b(b,:) = histcounts(logx1b,binsGroups);
        hist2b(b,:) = histcounts(logx2b,binsGroups);
        hist3b(b,:) = histcounts(logx3b,binsGroups);
        dhistb1(b,:) = hist1b(b,:) - hist3b(b,:);
        dhistb2(b,:) = hist2b(b,:) - hist3b(b,:);
    end
    % Representaciones
    hh1 = mean(hist1b(:,~posNaNs1),1); hh1T = hh1/(sum(mean(hist3b,1))+sum(mean(hist1b,1))); hh1 = hh1/sum(hh1);
    hh2 = mean(hist2b(:,~posNaNs2),1); hh2T = hh2/(sum(mean(hist3b,1))+sum(mean(hist2b,1))); hh2 = hh2/sum(hh2);
    hh3 = mean(hist3b(:,~posNaNs3),1); hh3T1 = hh3/(sum(mean(hist3b,1))+sum(mean(hist1b,1))); hh3T2 = hh3/(sum(mean(hist3b,1))+sum(mean(hist2b,1))); hh3 = hh3/sum(hh3);
    normdhistb1=dhistb1/(sum(mean(hist1b,1))+sum(mean(hist3b,1)));
    normdhistb2=dhistb2/(sum(mean(hist2b,1))+sum(mean(hist3b,1)));
    nameVar=strrep(varNames{2},'_',' '); if ~isempty(trsFnc); nameVar=sprintf('%s(%s)',trsFnc{1}(2:end),nameVar); end
    % Figura -> Top vs. Normal
    figure('Name','Top vs. Normal','NumberTitle','off'); title(nameVar);%title([nameVar, ' ', valueFilter]);
    subplot(3,2,1); plot(means1,hh1); hold on; plot(means3,hh3); xlabel(nameVar); ylabel('pdf','Interpreter','Latex'); axis tight; legend('Top','Normal'); set(gca,'FontSize',16,'FontName','Times'); yl=ylim;
    subplot(3,2,3); plot(means1,hh1T); hold on; plot(means3,hh3T1); xlabel(nameVar); ylabel('normalized pdf','Interpreter','Latex'); axis tight; legend('Top','Normal'); set(gca,'FontSize',16,'FontName','Times'); ylim(yl);
    subplot(3,2,5); pintaICgris(normdhistb1,[],CI,binsGroups(1:end-1)); xlabel(nameVar); ylabel('$\Delta$ pdf','Interpreter','Latex'); axis tight; set(gca,'FontSize',16,'FontName','Times'); yl=ylim; if abs(yl(1)/yl(2))<.1; yl(1)=-max(abs(yl(1)),abs(.2*yl(2))); elseif abs(yl(2)/yl(1))<.1; yl(2)=max(abs(yl(2)),abs(.2*yl(1))); end; ylim(yl);
    subplot(3,2,[2 4 6]); histogram(dm1b,50,'Normalization','pdf'); hold on; histogram(ds1b,50,'Normalization','pdf'); hl=legend('$\Delta mean$','$\Delta std$'); set(hl,'Interpreter','Latex'); xlabel(nameVar,'Interpreter','Latex'); ylabel('pdf','Interpreter','Latex'); axis tight; set(gca,'FontSize',16,'FontName','Times')
    if sign(max(dm1b))==sign(min(dm1b)) && sign(max(ds1b))==sign(min(ds1b)); xl=xlim; if sign(max(dm1b))>0; xl(1)=-.1*xl(2); else; xl(2)=-.1*xl(1); end; xlim(xl); end
    yl=ylim; plot(zeros(1,2),[0 yl(2)],'Linewidth',1.2,'Color',[237,185,49]/255);%[248,215,74]/255);
    % Figura -> Small vs. Normal
    figure('Name','Small vs. Normal','NumberTitle','off'); title(nameVar);%title([nameVar, ' ', valueFilter]);
    subplot(3,2,1); plot(means2,hh2); hold on; plot(means3,hh3); xlabel(nameVar); ylabel('pdf','Interpreter','Latex'); axis tight; legend('Small','Normal'); set(gca,'FontSize',16,'FontName','Times'); yl=ylim;
    subplot(3,2,3); plot(means2,hh2T); hold on; plot(means3,hh3T2); xlabel(nameVar); ylabel('normalized pdf','Interpreter','Latex'); axis tight; legend('Small','Normal'); set(gca,'FontSize',16,'FontName','Times'); ylim(yl);
    subplot(3,2,5); pintaICgris(normdhistb2,[],CI,binsGroups(1:end-1)); xlabel(nameVar); ylabel('$\Delta$ pdf','Interpreter','Latex'); axis tight; set(gca,'FontSize',16,'FontName','Times'); yl=ylim; if abs(yl(1)/yl(2))<.1; yl(1)=-max(abs(yl(1)),abs(.2*yl(2))); elseif abs(yl(2)/yl(1))<.1; yl(2)=max(abs(yl(2)),abs(.2*yl(1))); end; ylim(yl);
    subplot(3,2,[2 4 6]); histogram(dm2b,50,'Normalization','pdf'); hold on; histogram(ds2b,50,'Normalization','pdf'); hl=legend('$\Delta mean$','$\Delta std$'); set(hl,'Interpreter','Latex'); xlabel(nameVar,'Interpreter','Latex'); ylabel('pdf','Interpreter','Latex'); axis tight; set(gca,'FontSize',16,'FontName','Times')
    if sign(max(dm2b))==sign(min(dm2b)) && sign(max(ds2b))==sign(min(ds2b)); xl=xlim; if sign(max(dm2b))>0; xl(1)=-.1*xl(2); else; xl(2)=-.1*xl(1); end; xlim(xl); end
    yl=ylim; plot(zeros(1,2),[0 yl(2)],'Linewidth',1.2,'Color',[237,185,49]/255);%[248,215,74]/255);
    % Diferencia de media y std para los cromosomas
    diffMean1=sum(sums1(:,1))/n1 - sum(sums3(:,1))/n3; diffStd1=sqrt(sum(sums1(:,3))/(n1-1)) - sqrt(sum(sums3(:,3))/(n3-1));
    diffMean2=sum(sums2(:,1))/n2 - sum(sums3(:,1))/n3; diffStd2=sqrt(sum(sums2(:,3))/(n2-1)) - sqrt(sum(sums3(:,3))/(n3-1));
    countings = [diffMean1 diffMean2 diffStd1 diffStd2];
    % Se determina si son significativas
    dataIC = miIC([dm1b(:),ds1b(:)],CI); indSelect = find((sign(dataIC(2,:))==sign(dataIC(3,:))) & not(sign(dataIC(2,:))==0));
    significativas{1}=false(1,2); significativas{1}(indSelect)=true;
    dataIC = miIC([dm2b(:),ds2b(:)],CI); indSelect = find((sign(dataIC(2,:))==sign(dataIC(3,:))) & not(sign(dataIC(2,:))==0));
    significativas{2}=false(1,2); significativas{2}(indSelect)=true;
end

ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
