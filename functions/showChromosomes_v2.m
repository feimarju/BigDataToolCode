function showChromosomes_v2(countings_G1_all,countings_G2_all,groupNames,varNames,significativas)

cromosom={}; variables={}; countvar=0; signifs=[];
for iv=1:length(varNames)
    if ~isempty(varNames{iv})
        if ~iscell(varNames{iv})
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
            [c,v,p]=addCromosom_v2(countings_G1,countings_G2,sumgrupos_G1,sumgrupos_G2,myTypes,myName);
            countvar=countvar+1; variables{countvar}=v; cromosom{countvar}=c;%/max(abs(c)); 
            if ~isempty(significativas{iv}); signifs{countvar}=significativas{iv}(p); end
            if length(v)==1; isnumeric(countvar)=true; else; isnumeric(countvar)=false; end
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
                    [c,v,p]=addCromosom_v2(countings_G1,countings_G2,sumgrupos_G1,sumgrupos_G2,myTypes,myName);
                    countvar=countvar+1; variables{countvar}=v; cromosom{countvar}=c;%/max(abs(c));
                    if ~isempty(significativas{iv}); signifs{countvar}=significativas{iv}{countIdt}(p); end
                    if length(v)==1; isnumeric(countvar)=true; else; isnumeric(countvar)=false; end
                end
            end
        end
    end
end

%% Se visualiza el cromosoma final
numPatchColor=[216,82,24]/255;
fcrom=figure; set(gcf, 'Position', get(0, 'Screensize')); h=axes(fcrom); hold on
infoTxt = uicontrol('Style','text','FontWeight','Bold','FontSize',16,'HorizontalAlignment','center','Units','normal','Position',[0.1 0.95 .8 .05]);
cromosomNN=cromosom(~isnumeric); cc=cat(2,cromosomNN{:}); minY=min(cc); maxY=max(cat(2,cc));
if isempty(minY); cromosomN=cromosom(isnumeric); cc=cat(2,cromosomN{:}); minY=min(cc); maxY=max(cat(2,cc)); end
numcats=0;
for iv=1:countvar
    borders=numcats+[1,length(cromosom{iv})]; yyaxis left;
    if isnumeric(iv); patch(h,[borders(1)-0.49 borders(2)+0.49 borders(2)+0.49 borders(1)-0.49],[minY minY maxY maxY],numPatchColor,'EdgeColor','None','FaceAlpha',.3);
    elseif ~mod(iv,2); patch(h,[borders(1)-0.49 borders(2)+0.49 borders(2)+0.49 borders(1)-0.49],[minY minY maxY maxY],[0.97 0.97 0.97],'EdgeColor','None');
    end
    name=strsplit(variables{iv}{1},':'); text(borders(1),maxY-.01-mod(iv,2)*.01,strrep(name{1},'_',' '))
    if isnumeric(iv); yyaxis right; end
    for ivj=1:length(cromosom{iv})
        ha=stem(h,borders(1)+ivj-1,cromosom{iv}(ivj),'-');
        if ivj==1; color=ha.Color; else; ha.Color=color; end
        if ~signifs{iv}(ivj); ha.Color(4)=0.3; ha.LineWidth=0.5; ha.Marker='none'; else; ha.Marker='o'; end
    end
    numcats=numcats+length(cromosom{iv});
end
axis tight; plot(floor(xlim)+[-.5 .5],zeros(1,2),'LineWidth',0.25,'Color','k'); axis tight
vnames=cat(2,variables{:}); xlabel('Analized categories and/or numerical variables','Interpreter','Latex'); yyaxis left; ylabel('$\Delta p$ (categorical/datetime/string vars)','Interpreter','Latex'); yyaxis right; ylabel('$\Delta mean$, $\Delta std$ (numerical vars)','Interpreter','Latex'); set(gca,'FontSize',16,'FontName','Times')
set(fcrom,'WindowButtonMotionFcn', {@showVariableName,h,infoTxt,vnames});

end

%% Se a?ade el cromosoma de cada variable al cromosoma total
function [cromosoms,variables,pos]=addCromosom_v2(countings_G1,countings_G2,sumgrupos_G1,sumgrupos_G2,myTypes,myName)
l = length(myTypes);
for k=1:l
    nombre=myTypes{k}; if strcmp(myTypes{k},''); nombre='NaN'; end
    %variables{k}=[reemplazaTildes(myName),': ',nombre];
    variables{k}=[remove_accents_from_string(myName),': ',nombre];
    cromosoms(k)=countings_G1(k)/sumgrupos_G1 - ...
        countings_G2(k)/sumgrupos_G2;
end
pos=1:length(cromosoms);
% [cromosoms,pos]=sort(cromosoms,'descend');
% variables=variables(pos);
end

%%
function showVariableName(~,~,hs,infoTxt,vnames)
cpFront = getXYZMousePosition(hs);
if ~isempty(cpFront) && round(cpFront(1))>0 && round(cpFront(1))<=length(vnames); xaxispos=round(cpFront(1)); infoTxt.String=vnames{xaxispos}; end
end

