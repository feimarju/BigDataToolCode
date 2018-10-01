function [dss,hist3D]=loadData(caso,pathToData)
if nargin<2; pathToData=''; end

readingFiles=fullfile(pathToData,caso,'FilesToRead.txt');
if exist(readingFiles,'file')==2
    fid=fopen(readingFiles); pathDB=textscan(fid,'%s'); pathDB=pathDB{1}; fclose(fid);
else
    fprintf('Please create a file called ''FilesToRead.txt'' into %s folder and inside write the paths of the files you want to read.\nIf you want to read all your files, type ''*. [Extension]'', where the extension can be ''xlsx'',''csv'',''txt''...\n');
end
scheme3DFiles=fullfile(pathToData,caso,'scheme3Dfiles.txt');
if exist(scheme3DFiles)==2; fid=fopen(scheme3DFiles); hist3D=textscan(fid,'%s'); fclose(fid); hist3D=hist3D{1}; hist3D={strsplit(hist3D{1},','),strsplit(hist3D{2},',')}; else; hist3D={}; end

fprintf('Loading data from %s database...\n',caso)
pathData=fullfile(pathToData,caso,pathDB{1});
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
fprintf('Done!\n')
