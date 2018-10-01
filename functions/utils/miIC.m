function dataIC = miIC(data,level)

% Intervalos de confianza mediante estadisticos ordenados
% Devuelve:
%
%   dataIC: media e intervalo de confianza (escalar o vector)
%       Calcula el IC de cada columna

% B filas y n columnas
[B,n] = size(data);

dataIC = NaN* zeros(3,n);    % Media, IClow, ICup
low = (100-level)/2; 
high = 100-low;

for i=1:n
    aux = data(:,i);
    ind = find(~isnan(aux));
    if not(isempty(ind))
        aux = aux(ind);
        dataIC(1,i) = mean(aux);
        aux = sort(aux);
        aux1 = floor(low/100*length(ind));
        if aux1 <1, aux1 = 1; end;
        aux2 = ceil( high/100*length(ind) );
        if aux2>B, aux1 = B; end;
        dataIC(2,i) = aux(aux1);
        dataIC(3,i) = aux(aux2);
    end
end
