%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: show M-Mode and return the significative categories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [significativas1,possorted1,significativas2,possorted2]=showMmodeAndCounts_v3(miHist1,miHist2,ejeHist,groupNames,grouperVar,valueFilter,countings_G1,countings_G2,countings_G3,CI)%,type)

%% Controles
Cs = uicontrol('Style','popup','String',{'--Sort cats (default: CI)--','CI','Counts'},'Units','normal','Position', [0.03 0.05 .2 .1],'Callback', @FSortType);
Cs2 = uicontrol('Style','popup','String',{'--Props. vs. Counts (default: Proportions)--','Proportions','Counts'},'Units','normal','Position', [0.03 .9 .2 .1],'Callback', @FXAxis);
Cs3 = uicontrol('Style','popup','String',{'--Hist (default: Hist)--','Hist.','Props.'},'Units','normal','Position', [0.03 .845 .2 .1],'Callback', @FChangePlot);
Cs4 = uicontrol('Style','popup','String',{'--Comparison (default: G1 vs. G2)--','G1 vs. G2','G3 vs. G2'},'Units','normal','Position', [0.03 .790 .2 .1],'Callback', @FChangeComparison);
input = uicontrol('Style','edit','String',sprintf('CI: %.1f%%',CI),'Units','normal','Position',[0.0429 0.0388 0.15 0.05],'Callback', @CIinput,'Visible','on');

%% Variables globales
ha=[]; typePlot=1; typeSort=1;
l=length(groupNames);
% G1 vs. G2
significativas1=false(1,l);
countCats1=countings_G1+countings_G2;
mh1=miHist1./repmat(max(miHist1,[],2),1,size(miHist1,2)); val=cell(1,3); pos1=val;
for i=1:l
    counts = mh1(i,:); empiricalCDF = cumsum(counts); empiricalCDF = empiricalCDF/empiricalCDF(end);
    indlow = find(empiricalCDF<=(100-CI)/100/2);
    if ~isempty(indlow); indlow = indlow(end); else; indlow=1; end
    indhigh = find(empiricalCDF>1-(100-CI)/100/2); indhigh = indhigh(1);
    ic = [ejeHist(indlow), ejeHist(indhigh)];
    if sign(ic(1))==sign(ic(2)) % significativas
        significativas1(i)=true;
        if sign(ic(2))>0; [val{1},newpos]=sort([val{1},ic(2)],'descend'); pos1{1}=[pos1{1},i]; pos1{1}=pos1{1}(newpos);
        else; [val{3},newpos]=sort([val{3},ic(1)],'descend'); pos1{3}=[pos1{3},i]; pos1{3}=pos1{3}(newpos);
        end
    else
        [val{2},newpos]=sort([val{2},ic(2)],'descend'); pos1{2}=[pos1{2},i]; pos1{2}=pos1{2}(newpos);
    end
end; pos=pos1; countCats=countCats1; mh=mh1; significativas=significativas1; %countings_GX=countings_G1; % Default option
% G3 vs. G2
significativas2=false(1,l);
countCats2=countings_G3+countings_G2;
mh2=miHist2./repmat(max(miHist2,[],2),1,size(miHist2,2)); val=cell(1,3); pos2=val;
for i=1:l
    counts = mh2(i,:); empiricalCDF = cumsum(counts); empiricalCDF = empiricalCDF/empiricalCDF(end);
    indlow = find(empiricalCDF<=(100-CI)/100/2);
    if ~isempty(indlow); indlow = indlow(end); else; indlow=1; end
    indhigh = find(empiricalCDF>1-(100-CI)/100/2); indhigh = indhigh(1);
    ic = [ejeHist(indlow), ejeHist(indhigh)];
    if sign(ic(1))==sign(ic(2)) % significativas
        significativas2(i)=true;
        if sign(ic(2))>0; [val{1},newpos]=sort([val{1},ic(2)],'descend'); pos2{1}=[pos2{1},i]; pos2{1}=pos2{1}(newpos);
        else; [val{3},newpos]=sort([val{3},ic(1)],'descend'); pos2{3}=[pos2{3},i]; pos2{3}=pos2{3}(newpos);
        end
    else
        [val{2},newpos]=sort([val{2},ic(2)],'descend'); pos2{2}=[pos2{2},i]; pos2{2}=pos2{2}(newpos);
    end
end
possorted1=cat(2,pos1{:}); possorted2=cat(2,pos2{:});
countCats3=countings_G1+countings_G2+countings_G3;

%% Ejecución inicial
showPlots(); return


%% Funciones
    function FChangeComparison(source,~)
        tc=source.Value-1; if tc==0; tc=1; end
        if tc==1
            pos=pos1; countCats=countCats1; mh=mh1; significativas=significativas1; %countings_GX=countings_G1;
        else
            pos=pos2; countCats=countCats2; mh=mh2; significativas=significativas2; %countings_GX=countings_G3;
        end
        if typePlot==1; showPlots(); else; showProps(); end
    end

    function FSortType(source,~)
        typeSort=source.Value-1; if typeSort==0; typeSort=1; end
        showPlots();
    end

    function FChangePlot(source,~)
        typePlot=source.Value-1; if typePlot==0; typePlot=1; end
        if typePlot==1; showPlots(); else; showProps(); end
    end

    function CIinput(source,~)
        getNumbers=@(x) regexp(x,'-?\d+\.?\d*|-?\d*\.?\d+','match');
        CI=cellfun(@str2num,getNumbers(source.String)); CI=CI(end);
        input.String=sprintf('CI: %.1f%%',CI);
        [significativas1,pos1]=updateCI(mh1);
        [significativas2,pos2]=updateCI(mh2);
        FChangeComparison(Cs4)
    end

    function FXAxis(source,~)
        XAxis=source.Value-1; if XAxis==0; XAxis=1; end
        %showPlots(); 
        if typePlot==2; tick='ZTick'; label='ZTickLabel'; else; tick='YTick'; label='YTickLabel'; end
        ticks=get(gca,tick); if max(abs(ticks))>1; ticks=ticks/sum(countCats); end; ticks(abs(ticks)<1e-12)=0;
        if XAxis==1; set(gca,label,arrayfun(@(x) num2str(x),ticks,'UniformOutput',false)); if typePlot==2; zlabel('$p$','Interpreter','Latex','FontSize',16); else; ylabel('$\Delta p$','Interpreter','Latex','FontSize',16); end
        else; set(gca,label,arrayfun(@(x) num2str(x*sum(countCats)),ticks,'UniformOutput',false)); if typePlot==2; zlabel('$\#$','Interpreter','Latex','FontSize',16); else; ylabel('$\Delta \#$','Interpreter','Latex','FontSize',16); end
        end
    end

    function [signfi,posi]=updateCI(mhi)
        valn=cell(1,3); posi=valn; signfi=false(1,l);
        for i=1:l
            countsn = mhi(i,:);
            empiricalCDFn = cumsum(countsn);
            empiricalCDFn = empiricalCDFn/empiricalCDFn(end);
            indlown = find(empiricalCDFn<=(100-CI)/100/2);
            if ~isempty(indlown); indlown = indlown(end); else; indlown=1; end
            indhighn = find(empiricalCDFn>1-(100-CI)/100/2);
            indhighn = indhighn(1);
            icn = [ejeHist(indlown), ejeHist(indhighn)];
            if sign(icn(1))==sign(icn(2)) % significativas
                signfi(i)=true;
                if sign(icn(2))>0; [valn{1},newposn]=sort([valn{1},icn(2)],'descend'); posi{1}=[posi{1},i]; posi{1}=posi{1}(newposn);
                else; [valn{3},newposn]=sort([valn{3},icn(1)],'descend'); posi{3}=[posi{3},i]; posi{3}=posi{3}(newposn);
                end
            else
                [valn{2},newposn]=sort([valn{2},icn(2)],'descend'); posi{2}=[posi{2},i]; posi{2}=posi{2}(newposn);
            end
        end
    end

    function showPlots()
        if typeSort==1; possorted=cat(2,pos{:});
        elseif typeSort==2; [countCats_norm,possorted]=sort(countCats/sum(countCats));%,'descend');
        end
        for i=1:l
            aux=mh(possorted(i),:);
            ha=plot3(i*ones(size(aux)),ejeHist,aux);
            if significativas(possorted(i)) % significativas
                if isnumeric(groupNames{possorted(i)}); gname=num2str(groupNames{possorted(i)}); else; gname=groupNames{possorted(i)}; end
                [m,ind] = max(aux);
                tx=text(i,ejeHist(ind),m,strrep(gname,'_',' '));
                if rem(i,2)==0; tx.HorizontalAlignment = 'right'; end
                tx.FontSize=10;
            else % no significativas (casi transparentes)
                ha.Color(4)=0.3;
                ha.LineWidth=0.5;
            end
            hold on;
        end
        %title([strrep(grouperVar,'_',' '),'  ', strjoin(valueFilter,', ')],'Interpreter','Latex','FontSize',16);%, type]); %xticklabels(groupNames)
        title(strrep(grouperVar,'_',' '),'Interpreter','Latex','FontSize',16);%, type]); %xticklabels(groupNames)
        plot3([1 l],[0 0],[0 0],'k') %legend(groupNames),
        xlabel('category','Interpreter','Latex','FontSize',16),
        ylabel('$\Delta p$','Interpreter','Latex','FontSize',16), zlabel('Norm pdf','Interpreter','Latex','FontSize',16);
        hold off, grid on,
        %view([-89 88]); %ejes = axis; ejes(3:4) = [-.5 .5]; axis(ejes);
        view([123 80]);
        set(gca,'FontSize',12,'FontName','Times'); axis tight;
        %posNN=find(sum(mh)~=0); ejes=axis; ejes(3:4)=[ejeHist(posNN(1)-10) ejeHist(posNN(end)+10)]; axis(ejes);
        posNN=find(sum(mh)~=0); if posNN(1)>10; ejes=axis; ejes(3)=ejeHist(posNN(1)-10); axis(ejes); end; if posNN(end)<length(ejeHist)-10; ejes=axis; ejes(4)=ejeHist(posNN(end)+10); axis(ejes); end
        if typeSort==2; yl=ylim; hold on; plot3(1:l,repmat(yl(1),1,l),countCats_norm,'Color',[35,186,237]/255,'LineWidth',2); hold off; end
    end

    function showProps()
        [~,possorted3]=sort(countCats3/sum(countCats3));
        h1=plot3(ones(size(countings_G1)),(1:length(countings_G1))',countings_G1(possorted3)/sum(countCats3),'LineWidth',2); hold on
        h2=plot3(2*ones(size(countings_G2)),(1:length(countings_G2))',countings_G2(possorted3)/sum(countCats3),'LineWidth',2);
        h3=plot3(3*ones(size(countings_G3)),(1:length(countings_G3))',countings_G3(possorted3)/sum(countCats3),'LineWidth',2);
        axis tight; xlim([0 4]); set(gca,'XTick',[1 2 3],'XTickLabel',{'G1','G2','G3'});
        for i=1:length(significativas)
            if significativas1(possorted3(i)) % significativas
                if isnumeric(groupNames{possorted3(i)}); gname=num2str(groupNames{possorted3(i)}); else; gname=groupNames{possorted3(i)}; end
                if countings_G1(possorted3(i))>countings_G2(possorted3(i))
                    tx=text(1,i,countings_G1(possorted3(i))/sum(countCats3),strrep(gname,'_',' '));
                    tx.HorizontalAlignment='right'; tx.Position(1)=tx.Position(1)-.05;
                else; tx=text(2,i,countings_G2(possorted3(i))/sum(countCats3),strrep(gname,'_',' '));
                    tx.HorizontalAlignment='right'; tx.Position(1)=tx.Position(1)-.05;
                end; tx.FontSize=10;
            end
            if significativas2(possorted3(i)) % significativas
                if isnumeric(groupNames{possorted3(i)}); gname=num2str(groupNames{possorted3(i)}); else; gname=groupNames{possorted3(i)}; end
                if countings_G3(possorted3(i))<countings_G2(possorted3(i))
                tx=text(2,i,countings_G2(possorted3(i))/sum(countCats3),strrep(gname,'_',' '));
                tx.HorizontalAlignment='left'; tx.Position(1)=tx.Position(1)+.05;
                else; tx=text(3,i,countings_G3(possorted3(i))/sum(countCats3),strrep(gname,'_',' '));
                    tx.HorizontalAlignment='left'; tx.Position(1)=tx.Position(1)+.05;
                end; tx.FontSize=10;
            end
        end
        h1.Marker='o'; h1.MarkerIndices=find(significativas1(possorted3));
        h2.Marker='o'; h2.MarkerIndices=find(significativas1(possorted3) & significativas2(possorted3));
        h3.Marker='o'; h3.MarkerIndices=find(significativas2(possorted3));
        h4=plot3(repmat([1 2],sum(significativas1),1)',repmat(find(significativas1(possorted3))',1,2)',[countings_G1(possorted3(significativas1(possorted3)))/sum(countCats3) countings_G2(possorted3(significativas1(possorted3)))/sum(countCats3)]','LineWidth',.5);
        h5=plot3(repmat([2 3],sum(significativas2),1)',repmat(find(significativas2(possorted3))',1,2)',[countings_G2(possorted3(significativas2(possorted3)))/sum(countCats3) countings_G3(possorted3(significativas2(possorted3)))/sum(countCats3)]','LineWidth',.5);
        for ih=1:length(h4); if h4(ih).ZData(1)>h4(ih).ZData(2); h4(ih).Color=h1(1).Color; else; h4(ih).Color=h2(1).Color; end; end
        for ih=1:length(h5); if h5(ih).ZData(2)>h5(ih).ZData(1); h5(ih).Color=h3(1).Color; else; h5(ih).Color=h2(1).Color; end; end
        grid on; hold off
    end
end
