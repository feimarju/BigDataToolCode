function pintaICs(W,nivelIC)

if nargin<2; nivelIC=95; end

%aux = nanmean(W);
dataIC = miIC(W,nivelIC);
aux = sort(dataIC(1,:));
[~,indSorted]=sort(aux);
set(0,'DefaultTextFontSize', 14)

figure, clf
pintaICgris(W,indSorted,nivelIC);
title('Intervalos de confianza')
xlabel('Variables ordenadas de menor a mayor'), ylabel('"Importancia"')
