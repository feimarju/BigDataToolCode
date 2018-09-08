%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: show M-Mode and return the significative categories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [significativas,possorted]=showMmode(miHist,ejeHist,groupNames,grouperVar,valueFilter,l)%,type)
mh=miHist./repmat(max(miHist,[],2),1,size(miHist,2)); val=cell(1,3); pos=val;
% Se calcula la
significativas=false(1,l);
for i=1:l
    counts = mh(i,:);
    empiricalCDF = cumsum(counts);
    empiricalCDF = empiricalCDF/empiricalCDF(end);
    indlow = find(empiricalCDF<=.0005);
    if ~isempty(indlow); indlow = indlow(end); else indlow=1; end
    indhigh = find(empiricalCDF>.9995);
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
possorted=cat(2,pos{:});
for i=1:l
    hold on;
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
end
title([strrep(grouperVar,'_',' '),'  ', valueFilter],'Interpreter','Latex','FontSize',16);%, type]); %xticklabels(groupNames)
plot3([1 l],[0 0],[0 0],'k') %legend(groupNames),
xlabel('category','Interpreter','Latex','FontSize',16),
ylabel('$\Delta p$','Interpreter','Latex','FontSize',16), zlabel('Norm pdf','Interpreter','Latex','FontSize',16);
hold off, grid on, view([-89 88]); %ejes = axis; ejes(3:4) = [-.5 .5]; axis(ejes);
set(gca,'FontSize',12,'FontName','Times'); axis tight;
posNN=find(sum(mh)~=0); ejes=axis; ejes(3:4)=[ejeHist(posNN(1)-10) ejeHist(posNN(end)+10)]; axis(ejes);
