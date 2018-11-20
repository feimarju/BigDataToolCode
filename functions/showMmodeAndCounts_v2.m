%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: show M-Mode and return the significative categories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [significativas,possorted]=showMmodeAndCounts_v2(miHist,ejeHist,groupNames,grouperVar,valueFilter,countings_G1,countings_G2,CI)%,type)

Cs = uicontrol('Style','popup','String',{'--Sort cats (default: CI)--','CI','Counts'},'Units','normal','Position', [0.1 .9 .18 .1],'Callback', @FSortType);
Cs2 = uicontrol('Style','popup','String',{'--X-axis (default: \Delta P)--','\Delta P','\Delta \#'},'Units','normal','Position', [0.1 .845 .18 .1],'Callback', @FXAxis);
Cs3 = uicontrol('Style','popup','String',{'--Hist (default: Hist)--','Hist.','Props.'},'Units','normal','Position', [0.1 .790 .18 .1],'Callback', @FChangePlot);
input = uicontrol('Style','edit','String',sprintf('CI: %.1f%%',CI),'Units','normal','Position',[0.1125 0.7817 0.15 0.05],'Callback', @CIinput,'Visible','on');
ha=[]; showPlots(1);
countCats=countings_G1+countings_G2;

    function FSortType(source,~)
        type=source.Value-1; if type==0; type=1; end
        showPlots(type);
    end

    function FChangePlot(source,~)
        typePlot=source.Value-1; if typePlot==0; typePlot=1; end
        type=Cs.Value-1; if type==0; type=1; end
        if typePlot==1; showPlots(type);
        else; showProps();
        end
    end

    function CIinput(source,~)
        getNumbers=@(x) regexp(x,'-?\d+\.?\d*|-?\d*\.?\d+','match');
        CI=cellfun(@str2num,getNumbers(source.String)); CI=CI(end);
        input.String=sprintf('CI: %.1f%%',CI);
        FSortType(Cs,[])
    end

    function FXAxis(source,~)
        type=Cs.Value-1; if type==0; type=1; end
        XAxis=source.Value-1; if XAxis==0; XAxis=1; end
        showPlots(type); ticks=get(gca,'YTick'); if max(abs(ticks))>1; ticks=ticks/sum(countCats); end; ticks(abs(ticks)<1e-12)=0;
        if XAxis==1; set(gca,'YTickLabel',arrayfun(@(x) num2str(x),ticks,'UniformOutput',false)); ylabel('$\Delta p$','Interpreter','Latex','FontSize',16);
        else; set(gca,'YTickLabel',arrayfun(@(x) num2str(x*sum(countCats)),ticks,'UniformOutput',false)); ylabel('$\Delta \#$','Interpreter','Latex','FontSize',16);
        end
    end

    function showPlots(typeSort)
        if nargin<1; typeSort=1; end
        mh=miHist./repmat(max(miHist,[],2),1,size(miHist,2)); val=cell(1,3); pos=val;
        %countCats=countCats/sum(countCats);
        l=length(groupNames);
        significativas=false(1,l);
        for i=1:l
            counts = mh(i,:);
            empiricalCDF = cumsum(counts);
            empiricalCDF = empiricalCDF/empiricalCDF(end);
            indlow = find(empiricalCDF<=(100-CI)/100/2);
            if ~isempty(indlow); indlow = indlow(end); else; indlow=1; end
            indhigh = find(empiricalCDF>1-(100-CI)/100/2);
            indhigh = indhigh(1);
            ic = [ejeHist(indlow), ejeHist(indhigh)];
            if sign(ic(1))==sign(ic(2)) % significativas
                significativas(i)=true;
                if sign(ic(2))>0; [val{1},newpos]=sort([val{1},ic(2)],'descend'); pos{1}=[pos{1},i]; pos{1}=pos{1}(newpos);
                else; [val{3},newpos]=sort([val{3},ic(1)],'descend'); pos{3}=[pos{3},i]; pos{3}=pos{3}(newpos);
                end
            else
                [val{2},newpos]=sort([val{2},ic(2)],'descend'); pos{2}=[pos{2},i]; pos{2}=pos{2}(newpos);
            end
        end
        if typeSort==1; possorted=cat(2,pos{:});
        elseif typeSort==2; [countCats2,possorted]=sort(countCats/sum(countCats));%,'descend');
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
        title(strrep(grouperVar,'_',' '),'Interpreter','Latex','FontSize',16);%, type]); %xticklabels(groupNames)
        %title([strrep(grouperVar,'_',' '),'  ', strjoin(valueFilter,', ')],'Interpreter','Latex','FontSize',16);%, type]); %xticklabels(groupNames)
        plot3([1 l],[0 0],[0 0],'k') %legend(groupNames),
        xlabel('category','Interpreter','Latex','FontSize',16),
        ylabel('$\Delta p$','Interpreter','Latex','FontSize',16), zlabel('Norm pdf','Interpreter','Latex','FontSize',16);
        hold off, grid on,
        %view([-89 88]); %ejes = axis; ejes(3:4) = [-.5 .5]; axis(ejes);
        view([123 80]);
        set(gca,'FontSize',12,'FontName','Times'); axis tight;
        %posNN=find(sum(mh)~=0); ejes=axis; ejes(3:4)=[ejeHist(posNN(1)-10) ejeHist(posNN(end)+10)]; axis(ejes);
        posNN=find(sum(mh)~=0); if posNN(1)>10; ejes=axis; ejes(3:4)=[ejeHist(max(1,posNN(1)-10)) ejeHist(min(length(ejeHist),posNN(end)+10))]; axis(ejes); end
        if typeSort==2; yl=ylim; hold on; plot3(1:l,repmat(yl(1),1,l),countCats2,'Color',[35,186,237]/255,'LineWidth',2); hold off; end
    end

    function showProps()
        %mh=miHist./repmat(max(miHist,[],2),1,size(miHist,2)); val=cell(1,3); pos=val;
        %if typeSort==1; possorted=cat(2,pos{:});
        %elseif typeSort==2; [~,possorted]=sort(countCats/sum(countCats));%,'descend');
        %end
        [~,possorted]=sort(countCats/sum(countCats));
        h1=plot3(ones(size(countings_G1)),(1:length(countings_G1))',countings_G1(possorted)); hold on
        h2=plot3(2*ones(size(countings_G2)),(1:length(countings_G2))',countings_G2(possorted));
        xlim([0 3]); set(gca,'XTick',[1 2],'XTickLabel',{'G1','G2'});
        for i=1:length(significativas)
            if significativas(possorted(i)) % significativas
                if isnumeric(groupNames{possorted(i)}); gname=num2str(groupNames{possorted(i)}); else; gname=groupNames{possorted(i)}; end
                tx=text(1,i-.4,countings_G1(possorted(i)),strrep(gname,'_',' '));
                %if rem(i,2)==0; tx.HorizontalAlignment = 'right'; end
                tx.FontSize=10;
            %else % no significativas (casi transparentes)
                %ha.Color(4)=0.3;
                %ha.LineWidth=0.5;
            end
            %hold on;
        end
        h1.Marker='o'; h1.MarkerIndices=find(significativas(possorted));
        h2.Marker='o'; h2.MarkerIndices=find(significativas(possorted));
        hold off
    end
end
