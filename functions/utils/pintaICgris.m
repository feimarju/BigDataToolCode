function pintaICgris(Xboot,indSorted,nivelIC,xticks)

if nargin<2 || isempty(indSorted); indSorted=1:size(Xboot,2); end
if nargin<3 || isempty(nivelIC); nivelIC=95; end
if nargin<4; xticks=1:length(indSorted); end

dataIC = miIC(Xboot(:,indSorted),nivelIC);
[~,m] = size(dataIC);

indSelect = find((sign(dataIC(2,:))==sign(dataIC(3,:))) & ...
        not(sign(dataIC(2,:))==0));   
    
stem(xticks(indSelect),ones(1,length(indSelect))*max(dataIC(3,:)),':r','Marker','None'), hold on
stem(xticks(indSelect),ones(1,length(indSelect))*min(dataIC(2,:)),':r','Marker','None')

% figure(2)
plot(xticks,dataIC(1,:),'.-'), grid on, hold on
box on;
%text(1:length(indSorted), dataIC(1,:)-0.02, cellstr(num2str(indSorted(:))), 'FontSize', 18);
mipolix = xticks([1:m, m:-1:1]);
mipoliy = [dataIC(2,:), dataIC(3,end:-1:1)];

fill(mipolix,mipoliy,[.2,.2,.2]); alpha(.5), 
axis tight
ejes = axis;
plot([ejes(1) ejes(2)],[0 0],'k')
hold off

legend(['CI ' num2str(nivelIC) '%'])
