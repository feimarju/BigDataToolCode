function pintaICs2(W,dataIC,dictionary,significativas)

% Se ordenan de mayor a menor (si no se quiere ordenar, comentar las dos siguientes l?neas)
[dataIC,pos] = sort(dataIC(1,:));
dictionary=dictionary(pos); significativas=significativas(pos); W=W(:,pos);
M = max(W(:)); m = min(W(:)); l = max(abs([M m]));
ejehist = linspace(-l,l,300);

if nargin<4
    idx=sign(dataIC(2,:))==sign(dataIC(3,:));
    significativas=false(1,size(dataIC,2)); significativas(idx)=true;
end

[~,nwords] = size(W);

figure,
for i=1:nwords
    hold on;
    aux = hist(W(:,i),ejehist);
    aux = aux/max(aux);
    ha=plot3(i*ones(size(aux)),ejehist,aux);  
    [m,ind] = max(aux);
    if significativas(i)
        text(i,ejehist(ind),m,dictionary{i})
    else % no significativas (casi transparentes)
        ha.Color(4)=0.3;
        ha.LineWidth=0.5;
    end
end
%title([grouperVar, ' ', valueFilter]); 
%xticklabels(groupNames)
%plot3([1 l],[0 0],[0 0],'k')
%legend(groupNames),
xlabel('words'), axis tight
ylabel('\Delta pdf'), zlabel('Norm pdf');
hold off, grid on,
axis tight
