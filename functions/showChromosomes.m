function showChromosomes(countings,groupNames,varNames,significativas)%,umbral)

cromosom={}; variables={}; countvar=0; signifs=[];
for iv=1:length(varNames)
    if ~isempty(varNames{iv})
        if ~iscell(varNames{iv})
            myCountingsAll = sum(table2array(countings{iv}),1);
            sumgrupos = [sum(myCountingsAll(1:end/2)) sum(myCountingsAll(end/2+1:end))];
            if length(myCountingsAll)==2; sumgrupos=[sum(myCountingsAll) sum(myCountingsAll)]; end
            myTypes=groupNames{iv};
            myName=varNames{iv};
            [c,v,p]=addCromosom(myCountingsAll,sumgrupos,myTypes,myName);
            countvar=countvar+1; variables{countvar}=v; cromosom{countvar}=c;%/max(abs(c)); 
            if ~isempty(significativas{iv}); signifs{countvar}=significativas{iv}(p); end
        else
            countIdt=0;
            for idt=1:length(varNames{iv})
                if ~isempty(varNames{iv}{idt})
                    countIdt=countIdt+1;
                    myCountingsAll = sum(table2array(countings{iv}{idt}),1);
                    sumgrupos = [sum(myCountingsAll(1:end/2)) sum(myCountingsAll(end/2+1:end))];
                    if length(myCountingsAll)==2; sumgrupos=[1 1]; end
                    myTypes=groupNames{iv}{idt};
                    myName=varNames{iv}{idt};
                    [c,v,p]=addCromosom(myCountingsAll,sumgrupos,myTypes,myName);
                    countvar=countvar+1; variables{countvar}=v; cromosom{countvar}=c;%/max(abs(c));
                    if ~isempty(significativas{iv}); signifs{countvar}=significativas{iv}{countIdt}(p); end
                end
            end
        end
    end
end

%if nargin<4; umbral=0.08; end

%% Se visualiza el cromosoma final
fcrom=figure; set(gcf, 'Position', get(0, 'Screensize')); h=axes(fcrom); hold on
infoTxt = uicontrol('Style','text','FontWeight','Bold','FontSize',16,'HorizontalAlignment','center','Units','normal','Position',[0.1 0.95 .8 .05]);
numcats=0; minY=min(cat(2,cromosom{:})); maxY=max(cat(2,cromosom{:}));
for iv=1:countvar
    borders=numcats+[1,length(cromosom{iv})];
    if ~mod(iv,2); patch(h,[borders(1) borders(2) borders(2) borders(1)],[minY minY maxY maxY],[0.95 0.95 0.95],'EdgeColor','None'); end
    for ivj=1:length(cromosom{iv})
        ha=stem(h,borders(1)+ivj-1,cromosom{iv}(ivj));
        if ivj==1; color=ha.Color; else; ha.Color=color; end
        if ~signifs{iv}(ivj); ha.Color(4)=0.3; ha.LineWidth=0.5; ha.Marker='none'; end
    end
    numcats=numcats+length(cromosom{iv});
end
axis tight
vnames=cat(2,variables{:});
set(fcrom,'WindowButtonMotionFcn', {@showVariableName,h,infoTxt,vnames});

end

%% Se a?ade el cromosoma de cada variable al cromosoma total
function [cromosoms,variables,pos]=addCromosom(myCountingsAll,sumgrupos,myTypes,myName)
l = length(myTypes);
for k=1:l
    nombre=myTypes{k}; if strcmp(myTypes{k},''); nombre='NaN'; end
    %variables{k}=[reemplazaTildes(myName),': ',nombre];
    variables{k}=[remove_accents_from_string(myName),': ',nombre];
    cromosoms(k)=myCountingsAll(k)/sumgrupos(1) - ...
        myCountingsAll(k+l)/sumgrupos(2);
end
[cromosoms,pos]=sort(cromosoms,'descend');
variables=variables(pos);
end

%%
function showVariableName(~,~,hs,infoTxt,vnames)
cpFront = getXYZMousePosition(hs);
if ~isempty(cpFront) && round(cpFront(1))>0 && round(cpFront(1))<=length(vnames); xaxispos=round(cpFront(1)); infoTxt.String=vnames{xaxispos}; end
end

