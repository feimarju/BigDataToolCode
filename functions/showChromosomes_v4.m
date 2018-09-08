function showChromosomes_v4(countings_G1_all,countings_G2_all,groupNames,varNames,significativas,title)

cromosom={}; variables={}; countvar=0; signifs=[]; showProps=0;
for iv=1:length(varNames)
    if ~isempty(varNames{iv})
        if ~iscell(varNames{iv})
            if length(groupNames{iv})==1 && ~istable(countings_G1_all{iv}) % Numerical var
                name=strrep(remove_accents_from_string(varNames{iv}),'_',' ');
                v={}; v{1}=[name,': \Delta mean']; v{2}=[name,': \Delta std'];
                c=[]; c(1)=countings_G1_all{iv}; c(2)=countings_G2_all{iv}; p=1:2;
                countvar=countvar+1; variables{countvar}=v; cromosom{countvar}=c;%/max(abs(c));
                if ~isempty(significativas{iv}); signifs{countvar}=significativas{iv}(p); end
                isnumeric(countvar)=true; props{countvar}=[];
                continue
            end
            if size(countings_G1_all{iv},2)==1
                countings_G1 = table2array(countings_G1_all{iv});
                countings_G2 = table2array(countings_G2_all{iv});
            else
                countings_G1 = sum(table2array(countings_G1_all{iv}),1);
                countings_G2 = sum(table2array(countings_G2_all{iv}),1);
            end
            if length(countings_G1)>1; sumgrupos_G1 = sum(countings_G1); else; sumgrupos_G1=1; end
            if length(countings_G2)>1; sumgrupos_G2 = sum(countings_G2); else; sumgrupos_G2=1; end
            if sumgrupos_G1==1 && sumgrupos_G2==1; sumgrupos_G1=sum(countings_G1)+sum(countings_G2); sumgrupos_G2=sumgrupos_G1; end
            myTypes=groupNames{iv};
            myName=varNames{iv};
            [c,v,p,pr]=addCromosom_v2(countings_G1,countings_G2,sumgrupos_G1,sumgrupos_G2,myTypes,myName);
            countvar=countvar+1; variables{countvar}=v; cromosom{countvar}=c;%/max(abs(c));
            props{countvar}=pr;
            if ~isempty(significativas{iv}); signifs{countvar}=significativas{iv}(p); end
            isnumeric(countvar)=false;
            %if length(v)==1; isnumeric(countvar)=true; else; isnumeric(countvar)=false; end
        else
            countIdt=0;
            for idt=1:length(varNames{iv})
                if ~isempty(varNames{iv}{idt})
                    countIdt=countIdt+1;
                    if size(countings_G1_all{iv}{idt},2)==1
                        countings_G1 = table2array(countings_G1_all{iv}{idt});
                        countings_G2 = table2array(countings_G2_all{iv}{idt});
                    else
                        countings_G1 = sum(table2array(countings_G1_all{iv}{idt}),1);
                        countings_G2 = sum(table2array(countings_G2_all{iv}{idt}),1);
                    end
                    if length(countings_G1)>1; sumgrupos_G1 = sum(countings_G1); else; sumgrupos_G1=1; end
                    if length(countings_G2)>1; sumgrupos_G2 = sum(countings_G2); else; sumgrupos_G2=1; end
                    myTypes=groupNames{iv}{idt};
                    myName=varNames{iv}{idt};
                    [c,v,p,pr]=addCromosom_v2(countings_G1,countings_G2,sumgrupos_G1,sumgrupos_G2,myTypes,myName);
                    countvar=countvar+1; variables{countvar}=v; cromosom{countvar}=c;%/max(abs(c));
                    props{countvar}=pr;
                    if ~isempty(significativas{iv}); signifs{countvar}=significativas{iv}{countIdt}(p); end
                    if length(v)==1; isnumeric(countvar)=true; else; isnumeric(countvar)=false; end
                end
            end
        end
    end
end

%% Se visualiza el cromosoma final
fcrom=figure('Name',title,'NumberTitle','off'); set(gcf, 'Position', get(0, 'Screensize'));
infoTxt = uicontrol('Style','text','FontWeight','Bold','FontSize',16,'HorizontalAlignment','center','Units','normal','Position',[0.1 0.95 .8 .05]);
Cs{1} = uicontrol('Style','popup','String',{'Signif. order','Prop. order'},'Units','normal','Position', [0.015 0.85 .105 .1],'Callback', @(s,e) FchooseOrder(s,e,cromosom,variables,signifs,props));
Cs{2} = uicontrol('Style','checkbox','String','Show Props.','Units','normal','Position',[0.0193 0.8650 0.0722 0.05],'Callback',@setProps,'Visible','on','Value',0);
visualizeChromosomes(cromosom,variables,signifs,props)

%%
    function visualizeChromosomes(cromosom,variables,signifs,props)
        set(fcrom,'WindowButtonMotionFcn',{});
        delete(findobj(fcrom,'Type','Axes')); h=axes(fcrom); hold on
        cromosomNN=cromosom(~isnumeric); cc=cat(2,cromosomNN{:}); minY=min(cc); maxY=max(cat(2,cc));
        if isempty(minY); cromosomN=cromosom(isnumeric); cc=cat(2,cromosomN{:}); minY=min(cc); maxY=max(cat(2,cc)); end
        if showProps && sum(~isnumeric)>0; maxY=max(maxY,max(cat(2,props{:}))); minY=min(minY,min(cat(2,props{:}))); end
        numcats=0; numPatchColor=[216,82,24]/255;
        for iv=1:countvar
            borders=numcats+[1,length(cromosom{iv})]; yyaxis left;
            if isnumeric(iv); patch(h,[borders(1)-0.49 borders(2)+0.49 borders(2)+0.49 borders(1)-0.49],[minY minY maxY maxY],numPatchColor,'EdgeColor','None','FaceAlpha',.3);
            elseif ~mod(iv,2); patch(h,[borders(1)-0.49 borders(2)+0.49 borders(2)+0.49 borders(1)-0.49],[minY minY maxY maxY],[0.97 0.97 0.97],'EdgeColor','None');
            end
            if ~isnumeric(iv); name=strsplit(variables{iv}{1},':'); text(borders(1),maxY-.01-mod(iv,2)*.01,strrep(name{1},'_',' ')); end
            if isnumeric(iv); yyaxis right; end
            for ivj=1:length(cromosom{iv})
                ha=stem(h,borders(1)+ivj-1,cromosom{iv}(ivj),'-');
                if ivj==1; color=ha.Color; else; ha.Color=color; end
                if ~signifs{iv}(ivj); ha.Color(4)=0.3; ha.LineWidth=0.5; ha.Marker='none'; else; ha.Marker='o'; end
                if showProps && ~isempty(props{iv}); stem(h,borders(1)+ivj-1,props{iv}(ivj),':*r','MarkerSize',3); end
            end
            numcats=numcats+length(cromosom{iv});
        end
        axis tight; plot(floor(xlim)+[-.5 .5],zeros(1,2),'LineWidth',0.25,'Color','k','Marker','none'); axis tight;
        xlabel('Analyzed categories and numerical variables','Interpreter','Latex'); yyaxis left; ylabel('$\Delta p$ (categorical/datetime/string vars)','Interpreter','Latex'); yyaxis right; ylabel('$\Delta mean$, $\Delta std$ (numerical vars)','Interpreter','Latex'); set(gca,'FontSize',16,'FontName','Times')
        vnames=cat(2,variables{:}); set(fcrom,'WindowButtonMotionFcn', {@showVariableName,h,infoTxt,vnames});
        % Se ajustan los ejes y para que coincidan los ceros
        yyaxis left; ylim2 = ylim; % Retrieve Ylim of second axis
        ratio = ylim2(1)/ylim2(2); % Ratio of negative leg to positive one (keep sign)
        yyaxis right; ylim1 = ylim; % Set same ratio for first axis
        if sum(ylim1-ylim2)>1e-12 && ylim1(2)~=0; ylim([ylim1(2)*ratio ylim1(2)]); end; hold off
    end

%%
    function showVariableName(~,~,hs,infoTxt,vnames)
        cpFront = getXYZMousePosition(hs);
        if ~isempty(cpFront) && round(cpFront(1))>0 && round(cpFront(1))<=length(vnames); xaxispos=round(cpFront(1)); infoTxt.String=vnames{xaxispos}; end
    end

%%
    function FchooseOrder(source,~,cromosom,variables,signifs,props)
        if source.Value==2
            for i=1:length(props)
                if ~isempty(props{i})
                    [props{i},pos]=sort(props{i},'descend');
                    cromosom{i}=cromosom{i}(pos);
                    variables{i}=variables{i}(pos);
                    signifs{i}=signifs{i}(pos);
                end
            end
        end
        visualizeChromosomes(cromosom,variables,signifs,props)
    end

%%
    function setProps(source,~)
        showProps=source.Value;
        FchooseOrder(Cs{1},[],cromosom,variables,signifs,props)
    end

end

%% Se a?ade el cromosoma de cada variable al cromosoma total
function [cromosoms,variables,pos,counts_props]=addCromosom_v2(countings_G1,countings_G2,sumgrupos_G1,sumgrupos_G2,myTypes,myName)
l = length(myTypes);
for k=1:l
    nombre=myTypes{k}; if strcmp(myTypes{k},''); nombre='NaN'; end
    %variables{k}=[reemplazaTildes(myName),': ',nombre];
    variables{k}=[remove_accents_from_string(myName),': ',nombre];
    cromosoms(k)=countings_G1(k)/sumgrupos_G1 - ...
        countings_G2(k)/sumgrupos_G2;
    counts_props(k)=(countings_G1(k)+countings_G2(k))/sum(countings_G1+countings_G2);
end
pos=1:length(cromosoms);
% [cromosoms,pos]=sort(cromosoms,'descend');
% variables=variables(pos);
end

