function [dss,hist3D]=loadData(caso,pathToData)
if nargin<2; pathToData=''; end

%---------------------------  MOFIFICABLE ---------------------------------
casos={'CRE','Iberostar','REE','SCA','NH','ICOS','ECU911','CRG','EEG','Onco'};
pathDB={'CRE/datos/Datos*.xlsx',... %Datos*Jaen* %Datos 2014*      % CRE
    'Iberostar/PrimerProyecto/InformesURJC/Informe1.txt',...  % Iberostar
    'REE/ANOMALIAS2.xlsx',...                                 % REE
    'SCA/DatosSCA_v2_conU.xlsx',...                           % SCA
    'NH/tbl_MastroBranches.xlsx',...                          % NH
    'ICOS/ICOstats_v2.txt'...                                 % ICOS
    'ECU911/*_db.xlsx'...                                     % ECU911
    'CRG/tablaConjunta_reducida.txt'...                       % Cronicidad
    'EEG/exportar_grande.txt'...                              % EEG
    'Onco/supervivencia_v2.xlsx'...                              % Onco
    };
hists3D={...
    {{'Jaen','Alicante'},{'2014','2015','2016','2017'}},... % CRE
    {},...                                                  % Iberostar
    {},...                                                  % REE
    {},...                                                  % SCA
    {},...                                                  % NH
    {},...                                                  % ICOS
    {{'2014'},{'Febrero','Abril','Agosto'}},...             % ECU911
    {},...                                                  % CRG
    {},...                                                  % EEG
    {},...                                                  % Onco
    };
%--------------------------------------------------------------------------

if ~isnumeric(caso); caso=find(strcmp(casos,caso)); end
fprintf('Loading data from %s database...\n',casos{caso})
pathData=fullfile(pathToData,pathDB{caso});
parts=strsplit(pathData,'.'); extension=parts{end};
params={'ReadSize',5000};
switch extension
    case 'xlsx'; params=[params,'Type','spreadsheet'];
    case 'txt'; params=[params,'Type','tabulartext'];
end; if strcmp(pathData(end),'/'); params=[params,'Type','tall']; end
tic; dss{1} = datastore(pathData,params{:}); toc
if isa(dss{1},'matlab.io.datastore.SpreadsheetDatastore')
    sheets=sheetnames(dss{1},1);
    if length(sheets)>1
        for i=1:length(sheets)
            dss{i} = datastore(pathData,'Type','spreadsheet','Sheets',sheets{i},'ReadSize',5000);
            dss{i}.VariableTypes(strcmp(dss{i}.VariableTypes,'double'))={'char'}; % Se ponen todos los double a char, pues si en alguna fila tras el primer chunk de tama?o ReadSize hay un valor 'char', luego fallar?a. Esto se trata en la tool, pero si ocurre en muchas variables, puede llegar a tardar m?s hasta que se resuelven todos lo casos... Es preferible ponerlo a char y luego el usuario que lo ponga a double si quiere analizarlo as?. En la tool se trata internamente, as? no falla el datastore. Si se pulsa en guarda cambios, fallar?a el datastore.
        end
    end
elseif isa(dss{1},'matlab.io.datastore.TabularTextDatastore')
    %dss{1}=datastore(pathData);
    %dst{1}=[]; [dss,dst]=correctFormats(dss,dst);
    dss{1}.TextscanFormats(strcmp(dss{1}.TextscanFormats,'%f'))={'%q'};
end
hist3D=hists3D{caso};
fprintf('Done!\n')
