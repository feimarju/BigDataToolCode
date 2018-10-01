function BigDataTool_v7

if isempty(gcp('nocreate')); myCluster=parcluster('local'); parpool(myCluster,myCluster.NumWorkers); end
addpath(genpath('functions'))
%f=figure; set(gcf, 'Position', get(0, 'Screensize'));
f=figure; set(gcf,'Position',get(0,'Screensize'),'Color','white','ToolBar','None','MenuBar','none','Name','BigDataTool','NumberTitle','off');

partsPath=strsplit(pwd,filesep); pathToData=strjoin(partsPath(1:end-1),filesep);
pathToFigs='figures'; caso=''; typeFormat=1;
mylist = dir(fullfile(pathToData,'*Data')); listfolders={mylist(:).name}; isfolders={mylist(:).isdir}; posToRemove=zeros(1,length(listfolders));
for i=1:length(listfolders); if strcmp(listfolders{i},'.') || strcmp(listfolders{i},'..') || strcmp(listfolders{i},'.DS_Store') || isfolders{i}==0; posToRemove(i)=1; end; end
listfolders(logical(posToRemove))=[]; listfolders=[{'--Select DDBB--'},listfolders];

%% Global vars
dss={}; hist3D={}; nsheet=1; t={}; nsheets=1; nBins=1001; B=5000; saveHists=0;
VariableTypes={}; sheetnames{1}='Default'; threshold=0; porcs={}; CI=99.9;
formats{1}={'%q','%f','%D','%s'};%,'%q'};
formats{2}={'char','double','datetime','string'};%,'char'};
dateTypes={'hour','day','dayweek','month','year'};
dateFuncs={@hour,@day,@(x)day(x,'dayofweek'),@month,@year};
getNumbers=@(x) regexp(x,'-?\d+\.?\d*|-?\d*\.?\d+','match');
selectedDateTypes={}; numericFiltering={}; trsFnc={};
thminrep=20; % Nro. minimo de repeticiones para incluir una palabra en BOW
currentPos=1; numRows=10; N=100; data=[]; numThreshold=[]; thrType=1; isNumericalThr=false;

%% Controladores
separac=0.04; %spaceTypeButtons=0.33;
infoTxt = uicontrol('Style','text','FontWeight','Bold','FontSize',16,'HorizontalAlignment','center','Units','normal','Position',[0.1 0.95 .8 .05],'BackgroundColor','white');
Cs{1} = uicontrol('Style','popup','String',listfolders,'Units','normal','Position', [0.015 0.85 .105 .1],'Callback', @FchooseDDBB);
Cs{2} = uicontrol('Style','popup','String',{'--Choose threshold method-- (default: Pareto)','Pareto','6 sigma','3 groups'},'Units','normal','Position', [0.41 .24 .18 .1],'Callback', @FChooseTypeThreshold,'Visible','off');
Cs{3} = uicontrol('Style','popup','String',{'--Choose Analysis--','Hist. indiv.','Chromosoms','Bivar.','Export {X,Y}'},'Units','normal','Position', [0.015 0.85-separac .105 .1],'Callback', @FChooseAnalysis,'Visible','off');
t=uitable(f,'Units', 'Normalized', 'Position',[0, .35, 1, .51],'Visible','off');
menusheets = uicontrol('Style','popup','Units','normal','Position', [0.3 0.798 .105 .1],'Callback', @FChooseSheet,'Visible','off');
nextsheet = uicontrol('Units','normal','Style', 'pushbutton', 'String', 'Next sheet >>','Position', [.8284 .86 .07 .05],'Callback',@next,'Visible','off');
prevsheet = uicontrol('Units','normal','Style', 'pushbutton', 'String', '<< Previous sheet','Position', [.2043 .86 .07 .05],'Callback',@previous,'Visible','off');
nextrows = uicontrol('Units','normal','Style', 'pushbutton', 'String', 'Next 10 rows >>','Position', [.9044 .86 .08 .05],'Callback',@nextr,'Visible','off');
prevrows = uicontrol('Units','normal','Style', 'pushbutton', 'String', '<< Previous 10 rows','Position', [.1193 .86 .08 .05],'Callback',@previousr,'Visible','off');
ok{1} = uicontrol('Units','normal','Style', 'pushbutton', 'String', 'Save changes sheet','Position', [.12 .92 .07 .04],'Callback',@saveChanges,'Visible','off');
ok{2} = uicontrol('Units','normal','Style', 'pushbutton', 'String', 'Continue','Position', [.47 .86 .07 .05],'Callback',@getchromosoms,'Visible','off');
ok{3} = uicontrol('Units','normal','Style', 'pushbutton', 'String', 'Save groups','Position', [.25 .015 .07 .05],'Callback',@saveGroups,'Visible','off');
Ct{1} = uicontrol('Style','toggle','String','All','Units','normal','Position', [0.33+0.015 0.92 .05 .04],'Callback', @FToggleAllVars,'Visible','off');
Ct{2} = uicontrol('Style','toggle','String','Categorical','Units','normal','Position', [0.33+0.07 0.92 .07 .04],'Callback', @FToggleCategoricalVars,'Visible','off');
Ct{3} = uicontrol('Style','toggle','String','Numerical','Units','normal','Position', [0.33+0.145 0.92 .065 .04],'Callback', @FToggleNumericalVars,'Visible','off');
Ct{4} = uicontrol('Style','toggle','String','Dates','Units','normal','Position', [0.33+0.215 0.92 .05 .04],'Callback', @FToggleDatesVars,'Visible','off');
Ct{5} = uicontrol('Style','toggle','String','Text','Units','normal','Position', [0.33+0.27 0.92 .05 .04],'Callback', @FToggleTextVars,'Visible','off');
ts{1}=uitable(f,'Units','Normalized','Position',[0.02, .015, .2, .32],'Visible','off');
ts{2}=uitable(f,'Units','Normalized','Position',[0.78, .015, .2, .32],'Visible','off');
axs{1}=axes('Units','Normalized','Position',[0.3, .1076, .4, .2],'Visible','off');
inputs{1} = uicontrol('Style','edit','Units','normal','Position',[0.45 .0075 .09 .025],'Callback', @FInputThr,'Visible','off');
inputs{2} = uicontrol('Style','edit','String',sprintf('CI: %.2f%%',CI),'Units','normal','Position',[0.2030 0.9233 0.0463 0.028],'Callback', @getCI,'Visible','off');
helpButton = uicontrol('Units','normal','Style','pushbutton','String','Help','Position',[0.9083 0.9536 .07 .04],'Callback','helpdlg({''- "Group Dates": 1->hours; 2->days; 3->dayweek; 4->month; 5->year'',''- "Numeric filtering": example to apply a filter in a selected numeric variable: @(x) x>=0'',''- "num. transf": transformation for numerical vars., e.g., log transformation replacing 0 by 1e-3: @log10, 1e-3''})','Visible','on');
return

%% DATA LOADING functions
    function FchooseDDBB(source,~)
        caso=source.String{source.Value}; if source.Value==1; return; end
        set(infoTxt,'String','Loading DDBB...'); drawnow;
        pathToFigs=fullfile(pathToData,caso,pathToFigs);
        [dss,hist3D]=loadData(caso,pathToData);
        % Check variable types
        nsheets=length(dss);
        if nsheets>1
            fprintf('La BBDD cargada tiene %d tablas y sus nombres son:\n',nsheets);
            for ins=1:nsheets; sheetnames{ins}=dss{ins}.Sheets; fprintf('%d.- %s\n',ins,sheetnames{ins}); end
            menusheets.String=['--Select sheet--',sheetnames]; menusheets.Visible='on';
        end
        contextualizador
        Cs{3}.Visible='on';
        for ict=1:length(Ct); Ct{ict}.Visible='on'; end; ok{1}.Visible='on';
        set(infoTxt,'String','Ready'); drawnow;
    end

%% CONTEXTUALIZER functions
    function updateTable(); rowNames=cell(numRows,1); for ir=currentPos:currentPos+numRows-1; rowNames{ir-currentPos+1}=['#',num2str(ir)]; end; T=table2cell(data(currentPos:currentPos+numRows-1,:)); stringdates=string(T(:,strcmp(VariableTypes,'datetime') | strcmp(VariableTypes,'%D'))); stringdates(ismissing(stringdates))='missing'; T(:,strcmp(VariableTypes,'datetime') | strcmp(VariableTypes,'%D'))=cellstr(stringdates); t.Data(1:numRows,:)=T; t.RowName(1:numRows)=rowNames; end
    function nextr(~,~); if currentPos<N-numRows; currentPos=currentPos+numRows; updateTable(); end; end
    function previousr(~,~); if currentPos>1; currentPos=currentPos-numRows; updateTable(); end; end
    function contextualizador()
        tic; T=read(dss{nsheet}); toc
        if isprop(dss{nsheet},'VariableNames'); VariableNames=dss{nsheet}.VariableNames;
        else; VariableNames=T.Properties.VariableNames;
        end
        if isprop(dss{nsheet},'VariableTypes')
            VariableTypes=dss{nsheet}.VariableTypes;
            %VariableTypes(strcmp(VariableTypes,'char'))={'categorical'};
            typeFormat=2;
        elseif isprop(dss{nsheet},'TextscanFormats')
            typeFormat=1;
            VariableTypes=dss{nsheet}.TextscanFormats;
            %VariableTypes(strcmp(VariableTypes,'%q'))={'%C'};
            posDatetime=(~cellfun(@isempty,strfind(lower(VariableNames),'fecha')) | ~cellfun(@isempty,strfind(lower(VariableNames),'date')));
            VariableTypes(posDatetime)={'%D'}; % Datetime
            % dss{1}.SelectedFormats(cat(1,VariableTypes{:})==3)={'%{uuuu-MM-dd}D'};
        else
            VariableTypes=repmat({'double'},1,length(VariableNames));
            typeFormat=2;
        end
        T2=table2cell(T(1:numRows,:)); stringdates=string(T2(:,strcmp(VariableTypes,'datetime') | strcmp(VariableTypes,'%D'))); stringdates(ismissing(stringdates))='missing'; T2(:,strcmp(VariableTypes,'datetime') | strcmp(VariableTypes,'%D'))=cellstr(stringdates);
        %T2=cellfun(@(x) sprintf('<HTML><TABLE border=0 width=400 bgcolor="rgb(200,200,200)"><TD>%s</TD></TR> </table></html>', x),T2,'UniformOutput',false);
        T2(end+1,:)=num2cell(strcmp(VariableTypes,formats{typeFormat}{1}));
        T2(end+1,:)=num2cell(strcmp(VariableTypes,formats{typeFormat}{2}));
        T2(end+1,:)=num2cell(strcmp(VariableTypes,formats{typeFormat}{3}));
        T2(end+1,:)=num2cell(strcmp(VariableTypes,formats{typeFormat}{4}));
        T2(end+1,:)=cell(1,size(T,2));
        T2(end+1,:)=VariableTypes;
        T2(end+1,:)=num2cell(false(1,size(T,2)));
        for i=1:numRows; rowNames{i}=['#',num2str(i)]; end; rowNames{i+1}='Categorical'; rowNames{i+2}='Numerical'; rowNames{i+3}='Datetime'; rowNames{i+4}='Text'; rowNames{i+5}='Date format/num. transf.'; rowNames{i+6}='Format'; rowNames{i+7}='Selected vars.';
        t.Data=T2; t.ColumnName=T.Properties.VariableNames; t.RowName=rowNames;
        t.Data=[t.Data; num2cell(false(3,size(t.Data,2)))]; t.RowName{end+1}='Threshold Var.'; t.RowName{end+1}='Filtering Var.'; t.RowName{end+1}='Exploring groups/aggr. var'; t.RowName{end+1}='Group dates'; t.RowName{end+1}='Numeric Filtering'; t.RowName{end+1}='Supervised vars.';
        t.Data(23,:)=num2cell(false(1,size(t.Data,2)));
        t.ColumnEditable=true; t.CellEditCallback=@editFormats; t.Visible='on';
        %dss{nsheet}.ReadSize=oldreadsize;
        data=T; clear T; currentPos=1;
        if nsheets>1; nextsheet.Visible='on'; prevsheet.Visible='on'; else; nextsheet.Visible='off'; prevsheet.Visible='off'; end
        nextrows.Visible='on'; prevrows.Visible='on'; inputs{2}.Visible='on';
        set(infoTxt,'String',['Sheet: ',sheetnames{nsheet}]); drawnow;
    end
    function next(~,~); if nsheet<nsheets; nsheet=nsheet+1; VariableTypes={}; contextualizador; threshold=0; porcs={}; hideThrResults(); for its=1:2; ts{its}.Visible='off'; end; end; end
    function previous(~,~); if nsheet>1; nsheet=nsheet-1; VariableTypes={}; contextualizador; threshold=0; porcs={}; hideThrResults(); for its=1:2; ts{its}.Visible='off'; end; end; end
    function FChooseSheet(source,~); if source.Value==1; return; end; nsheet=source.Value-1; VariableTypes={}; contextualizador; threshold=0; porcs={}; hideThrResults(); for its=1:2; ts{its}.Visible='off'; end; end
    function editFormats(source,event)
        idx=event.Indices;
        row_selected=idx(1);
        column_selected=idx(2);
        %if row_selected==nrows; format=event.string; VariableTypes{column_selected}=['%{',format,'}D']; end
        if row_selected==15
            if strcmp(source.Data{16,column_selected},'datetime'); infoTxt.String='Sorry, this datetime cannot be modified...'; drawnow; return; end
            if source.Data{13,column_selected}; source.Data{16,column_selected}=['%{',event.NewData,'}D']; end
            if source.Data{12,column_selected}; trsFnc{column_selected}=strtrim(strsplit(event.NewData,',')); if length(trsFnc{column_selected})==2; infoTxt.String=sprintf('Transformation function fixed as %s. Zero values will be replaced to %s.',trsFnc{column_selected}{1},trsFnc{column_selected}{2}); else; infoTxt.String=sprintf('Transformation function fixed as %s.',trsFnc{column_selected}{1}); end; end
        end
        if row_selected==14 && event.NewData; source.Data{16,column_selected}=formats{typeFormat}{4}; for i=setdiff(2:5,2); source.Data{16-i,column_selected}=false; end; end
        if row_selected==13 && event.NewData; source.Data{16,column_selected}=formats{typeFormat}{3}; for i=setdiff(2:5,3); source.Data{16-i,column_selected}=false; end; end
        if row_selected==12 && event.NewData; source.Data{16,column_selected}=formats{typeFormat}{2}; for i=setdiff(2:5,4); source.Data{16-i,column_selected}=false; end; end
        if row_selected==11 && event.NewData; source.Data{16,column_selected}=formats{typeFormat}{1}; for i=setdiff(2:5,5); source.Data{16-i,column_selected}=false; end; end
        if row_selected==14 && ~event.NewData; source.Data{16,column_selected}=''; end
        if row_selected==13 && ~event.NewData; source.Data{16,column_selected}=''; end
        if row_selected==12 && ~event.NewData; source.Data{16,column_selected}=''; end
        if row_selected==11 && ~event.NewData; source.Data{16,column_selected}=''; end
        if row_selected>=18 && row_selected<21; posno=setdiff(find(cell2mat(source.Data(row_selected,:))),column_selected); for ins=1:length(posno); source.Data{row_selected,posno(ins)}=false; end; end
        if row_selected==18; if event.NewData; showHistThr(column_selected); inputs{1}.Visible='on'; else; hideThrResults(); end; end
        if row_selected==19; if event.NewData; fillingListBox('Filtering',column_selected); else; ts{2}.Visible='off'; end; end
        if row_selected==20; if event.NewData && ~source.Data{12,column_selected}; fillingListBox('Exploring groups',column_selected); else; ts{1}.Visible='off'; end; end
        if row_selected==21; types=cellfun(@str2num,getNumbers(event.EditData)); t.Data(row_selected,column_selected)={event.EditData}; if sum(types<1 | types>5); infoTxt.String='Write a Group Date from 1 to 5, thanks!'; drawnow; return; end; selectedDateTypes{column_selected}={}; for it=1:length(types); selectedDateTypes{column_selected}{it}=types(it); end; infoTxt.String=['Date groups fixed to ',event.EditData]; end%dateTypes{types(it)}; end; end
        if row_selected==22; numericFiltering{column_selected}=str2func(event.EditData); t.Data(row_selected,column_selected)={event.EditData}; infoTxt.String=['Numeric Filtering fixed to ',event.EditData]; end
    end
    function hideThrResults(); inputs{1}.Visible='off'; Cs{2}.Visible='off'; axs{1}.Visible='off'; set(get(axs{1},'Children'),'Visible','off'); axright=findobj(gcf,'Type','Axes','Visible','on'); if ~isempty(axright); axright.Visible='off'; set(get(axright,'Children'),'Visible','off'); end; end
    function saveChanges(~,~)
        for iv=1:length(VariableTypes); VariableTypes{iv}=t.Data{16,iv}; end
        if isprop(dss{nsheet},'SelectedVariableTypes')
            % En estos casos, de char a double puede fallar. El cambio se tratar? internamente en el programa
            VariableTypes2=VariableTypes;
            VariableTypes2(strcmp(VariableTypes,'double'))={'char'}; % Se ponen todos los double a char, pues si en alguna fila tras el primer chunk de tama?o ReadSize hay un valor 'char', luego fallar?a. Esto se trata en la tool, pero si ocurre en muchas variables, puede llegar a tardar m?s hasta que se resuelven todos lo casos... Es preferible ponerlo a char y luego el usuario que lo ponga a double si quiere analizarlo as?. En la tool se trata internamente, as? no falla el datastore. Si se pulsa en guarda cambios, fallar?a el datastore.
            dss{nsheet}.VariableTypes=VariableTypes2;
        else
            dss{nsheet}.SelectedFormats=VariableTypes;
        end
        %dss{nsheet}.SelectedFormats(cat(1,VariableTypes{:})==3)={'%{uuuu-MM-dd}D'}
    end
    function FToggleAllVars(source,~)
        if source.Value==source.Max
            for ict=2:length(Ct); Ct{ict}.Value=1; end
            t.Data(17,:)=num2cell(true(1,size(t.Data,2)));
        elseif source.Value==source.Min
            for ict=2:length(Ct); Ct{ict}.Value=0; end
            t.Data(17,:)=num2cell(false(1,size(t.Data,2)));
        end
    end
    function FToggleCategoricalVars(source,~)
        posCateg=cell2mat(t.Data(11,:));
        if source.Value==source.Max; t.Data(17,posCateg)=num2cell(true(1,sum(posCateg==1)));
        elseif source.Value==source.Min; t.Data(17,posCateg)=num2cell(false(1,sum(posCateg==1)));
        end
    end
    function FToggleNumericalVars(source,~)
        posNumer=cell2mat(t.Data(12,:));
        if source.Value==source.Max; t.Data(17,posNumer)=num2cell(true(1,sum(posNumer==1)));
        elseif source.Value==source.Min; t.Data(17,posNumer)=num2cell(false(1,sum(posNumer==1)));
        end
    end
    function FToggleDatesVars(source,~)
        posDates=cell2mat(t.Data(13,:));
        if source.Value==source.Max; t.Data(17,posDates)=num2cell(true(1,sum(posDates==1)));
        elseif source.Value==source.Min; t.Data(17,posDates)=num2cell(false(1,sum(posDates==1)));
        end
    end
    function FToggleTextVars(source,~)
        posText=cell2mat(t.Data(14,:));
        if source.Value==source.Max; t.Data(17,posText)=num2cell(true(1,sum(posText==1)));
        elseif source.Value==source.Min; t.Data(17,posText)=num2cell(false(1,sum(posText==1)));
        end
    end

%% DATA ANALYSIS functions
    function FChooseAnalysis(source,~)
        opt2=source.Value;
        if opt2==1; return; end
        switch opt2
            case 2; histogramIndividual()
            case 3; chromosoms()
            case 4; bivariate()
            case 5; exportMatrices()
        end
    end
    function histogramIndividual(); ok{2}.Visible='on'; ok{2}.Callback=@getHistogramIndividual; ok{2}.String='Get histograms!'; end
    function getHistogramIndividual(~,~)
        infoTxt.String='Computing histograms...'; drawnow;
        functMR={@histcounts_MR,@sort_MR}; % 1: categorical, 2: numerical, 3: datetime
        idxSelectedVars=find(cell2mat(t.Data(17,:)));
        selectedVars=t.ColumnName(idxSelectedVars);
        if isempty(selectedVars); infoTxt.String='Please, choose the variables you want to analyze in "Selected vars."'; drawnow; return; end
        for iv=1:length(selectedVars)
            idxv=idxSelectedVars(iv);
            if t.Data{11,idxv}; typeData=1;     % categorical
            elseif t.Data{12,idxv}; typeData=2; % numerical
            elseif t.Data{13,idxv}; typeData=3; % datetime
            elseif t.Data{14,idxv}; typeData=4; % string
            else; continue;                     % other
            end
            if typeData<3 && (typeData==1 || isempty(hist3D)) % if categorical or unique File
                kv_counts = functMR{typeData}(dss{nsheet},idxv);
                if isempty(kv_counts); infoTxt.String='Variable con todo NaNs... pasando a la siguiente variable...'; continue; end
                if typeData==1
                    [N,pos]=sort(cat(1,kv_counts.Value{:}),'descend');
                    c=kv_counts.Key(pos);
                    if isnumeric(N); Counts=num2cell(N); else; Counts=N; end; Category=c; table_count_vars=table(Category(:),Counts(:));
                    if saveHists; nameFolder=fullfile(pathToFigs,['Sheet',num2str(nsheet)]); if ~exist(nameFolder,'dir'); mkdir(nameFolder); end; nameFile=fullfile(nameFolder,sprintf('%d_%s.mat',idxv,t.ColumnName{idxv})); save(nameFile,'table_count_vars'); end
                end
                if isempty(hist3D)
                    if typeData==1     % categorical
                        pos=[]; almacen{1,1}=zeros(1,length(c));
                        for k=1:length(kv_counts.Key); pos(k)=find(strcmp(kv_counts.Key(k),c)); end
                        almacen{1,1}(pos) = cat(1,kv_counts.Value{:});
                    elseif typeData==2 % numerical
                        almacen{1,1} = cat(1,kv_counts.Value{1}(:));
                    end
                end
            end
            axes1={''}; axes2={''};
            if ~isempty(hist3D)
                axes1 = hist3D{1}; axes2 = hist3D{2}; almacen = cell(length(axes1),length(axes2));
                for ii=1:length(axes1)
                    for jj=1:length(axes2)
                        text=sprintf('%s:  %s (%d/%d) - %s (%d/%d)',selectedVars{iv},axes1{ii},ii,length(axes1),axes2{jj},jj,length(axes2)); set(infoTxt,'String',text); drawnow;
                        selector = ~cellfun(@isempty,strfind(dss{nsheet}.Files,axes1{ii})) & ...
                            ~cellfun(@isempty,strfind(dss{nsheet}.Files,axes2{jj}));
                        ds = partition(dss{nsheet},'Files',find(selector));
                        if typeData<3; kv_counts = functMR{typeData}(ds,idxv); end
                        if typeData==1     % categorical
                            pos=[]; almacen{ii,jj}=zeros(1,length(c));
                            if isnumeric(c(1)); for k=1:length(kv_counts.Key); pos(k)=find(kv_counts.Key(k)==c); end
                            else; for k=1:length(kv_counts.Key); pos(k)=find(strcmp(kv_counts.Key(k),c)); end
                            end
                            almacen{ii,jj}(pos) = cat(1,kv_counts.Value{:});
                        elseif typeData==2 % numerical
                            almacen{ii,jj} = cat(1,kv_counts.Value{1}(:));
                        elseif typeData==3 % datetime
                            for idt=1:length(selectedDateTypes{idxv})
                                idxType=selectedDateTypes{idxv}{idt};
                                dateType=dateTypes{idxType};
                                kv_counts = histcountsDate_MR(ds,idxv,dateType);
                                [~,pos]=sort(cat(1,kv_counts.Value{:}),'descend');
                                c=kv_counts.Key(pos); almacen{ii,jj}=zeros(1,length(c));
                                almacen{ii,jj}(pos) = cat(1,kv_counts.Value{:});
                                showHistIndividuals(almacen,axes1,axes2,idxv,typeData,dateType,idt);
                            end
                        end
                    end
                end
            end
            if typeData<3; showHistIndividuals(almacen,axes1,axes2,idxv,typeData); end
            %-------------------------------------------------------------%
            %%%%%%%%% OTROS HISTOGRAMAS CUANDO HAY UNA SOLA SHEET %%%%%%%%%
            if typeData==3 % datetime
                %if length(selectedDateTypes{idxv})~=1; infoTxt.String='Please, choose only one Group Date for threshold'; drawnow; return; end
                for igd=1:length(selectedDateTypes{idxv})
                    idxType=selectedDateTypes{idxv}{igd}; dateType=dateTypes{idxType};
                    kv_counts = histcountsDate_MR(dss{nsheet},idxv,dateType); if sum(strcmp(kv_counts.Key,'')); kv_counts.Key{strcmp(kv_counts.Key,'')}='NaN'; end
                    [val,pos]=sort(cat(1,kv_counts.Value{:}),'descend'); keys=kv_counts.Key(pos);
                    figure; bar(val); ylabel('#occurrence'); axis tight; grid on; lkeys=length(keys); if lkeys>100 && typeData<4; posk=round(linspace(1,length(keys),10)); keys=keys(posk); xticks=posk; else; xticks=1:lkeys; end; if iscell(keys); set(gca,'XTick',xticks); set(gca,'XTickLabel',keys); else; keys=arrayfun(@(x) {num2str(x)},keys); set(gca,'XTick',xticks); set(gca,'XTickLabel',keys); end; xtickangle(gca,45)
                end
            elseif typeData==1 % categorical or numerical
                kv_counts = histcounts_MR(dss{nsheet},idxv); if sum(strcmp(kv_counts.Key,'')); kv_counts.Key{strcmp(kv_counts.Key,'')}='NaN'; end
                [val,pos]=sort(cat(1,kv_counts.Value{:}),'descend'); keys=kv_counts.Key(pos);
                figure; bar(val); ylabel('#occurrence'); axis tight; grid on; lkeys=length(keys); if lkeys>100 && typeData<4; posk=round(linspace(1,length(keys),10)); keys=keys(posk); xticks=posk; else; xticks=1:lkeys; end; if iscell(keys); set(gca,'XTick',xticks); set(gca,'XTickLabel',keys); else; keys=arrayfun(@(x) {num2str(x)},keys); set(gca,'XTick',xticks); set(gca,'XTickLabel',keys); end; xtickangle(gca,45)
            elseif typeData==2
                if length(numericFiltering)>=idxv; numericFilt=numericFiltering{idxv}; else; numericFilt={}; end
                if length(trsFnc)>=idxv; trsFunc=trsFnc{idxv}; else; trsFunc={}; end
                kv_counts = histnumerical_MR(dss{nsheet},idxv,numericFilt,trsFunc);
                figure; plot(kv_counts.means,kv_counts.probs); ylabel('probability'); xlabel(strrep(selectedVars{iv},'_',' ')); axis tight; grid on;
            else % string
                kv_counts = bow_MR(dss{nsheet},idxv);
                val=cat(1,kv_counts.Value{:}); keys=kv_counts.Key(val>thminrep); val(val<=thminrep)=[]; [val,pos]=sort(val,'descend'); keys=keys(pos);
                figure; bar(val); ylabel('#occurrence'); axis tight; grid on; lkeys=length(keys); if lkeys>100 && typeData<4; posk=round(linspace(1,length(keys),10)); keys=keys(posk); xticks=posk; else; xticks=1:lkeys; end; if iscell(keys); set(gca,'XTick',xticks); set(gca,'XTickLabel',keys); else; keys=arrayfun(@(x) {num2str(x)},keys); set(gca,'XTick',xticks); set(gca,'XTickLabel',keys); end; xtickangle(gca,45)
            end
            title(strrep(t.ColumnName{idxv},'_',' '))
            % Se podr?a poner esta l?nea de visualizaci?n aqu? en com?n, pero en las fechas hay que visualizar por cada date_group que se elige...
            %figure; bar(val); ylabel('#occurrence'); axis tight; grid on; lkeys=length(keys); if lkeys>100 && typeData<4; posk=round(linspace(1,length(keys),10)); keys=keys(posk); xticks=posk; else; xticks=1:lkeys; end; if iscell(keys); set(gca,'XTick',xticks); set(gca,'XTickLabel',keys); else; keys=arrayfun(@(x) {num2str(x)},keys); set(gca,'XTick',xticks); set(gca,'XTickLabel',keys); end; xtickangle(gca,45)
        end
        infoTxt.String='Ready'; drawnow;
    end
    function chromosoms(); ok{2}.Visible='on'; ok{2}.Callback=@getchromosoms; ok{2}.String='Get chromosoms!'; end
    function getchromosoms(~,~)
        if isempty(threshold) || (~iscell(threshold) && length(threshold)==1 && isnan(threshold)); infoTxt.String='Threshold is NaN... please write a valid threshold in the edit field (e.g. Group 1 (G1) <= 2) and press ENTER'; drawnow; return; end
        selectedVars=find(cell2mat(t.Data(17,:)));
        if isempty(selectedVars); infoTxt.String='Please, choose the variables you want to analyze in "Selected vars."'; drawnow; return; end
        if sum(cell2mat(t.Data(18,:)))>0; thresholdVar=t.ColumnName{cell2mat(t.Data(18,:))}; else; set(infoTxt,'String','ERROR: Threshold var. has to be selected!'); drawnow; return; end
        if sum(cell2mat(t.Data(19,:)))>0; filteringVar=t.ColumnName{cell2mat(t.Data(19,:))}; else; filteringVar=[]; end
        if ~isempty(ts{2}.Data) && ~isempty(filteringVar); valueFilter=ts{2}.Data(cell2mat(ts{2}.Data(:,1)),2); else; valueFilter=''; end
        if sum(cell2mat(t.Data(20,:)))>0 && cell2mat(t.Data(12,cell2mat(t.Data(20,:)))); idxAggrVar=find(cell2mat(t.Data(20,:))); aggregationVar=t.ColumnName{idxAggrVar}; else; aggregationVar=[]; end
        countings_G1=cell(length(selectedVars),1); countings_G2=cell(length(selectedVars),1); hists=cell(length(selectedVars),1); significativas=cell(length(selectedVars),1);
        for isv=1:length(selectedVars)
            idxVar=selectedVars(isv);
            selectedVar=t.ColumnName{idxVar}; varName=t.ColumnName{idxVar};
            set(infoTxt,'String',['Please, wait... computing chromosoms... Analyzing ',selectedVar]); drawnow;
            if t.Data{11,idxVar}
                %%%%%%% VARIABLES CATEGORICAS %%%%%%%%
                if t.Data{13,cell2mat(t.Data(18,:))}; thrFnc=dateFuncs{selectedDateTypes{cell2mat(t.Data(18,:))}{1}}; else; thrFnc=[]; end
                if exist('idxAggrVar','var') && length(numericFiltering)>=idxAggrVar; numericFilt=numericFiltering{idxAggrVar}; else; numericFilt={}; end
                [countings_G1{idxVar},countings_G2{idxVar},countings_G3{idxVar},namegroups{idxVar}] = histmulti_MR_v5(dss{nsheet},thresholdVar,threshold,selectedVar,filteringVar,valueFilter,aggregationVar,numericFilt,thrFnc);
                varnames{idxVar}=varName;
                set(infoTxt,'String',['Please, wait... showing computed histograms of ',selectedVar,'...']); drawnow;
                nameFolder=fullfile(pathToFigs,['Sheet',num2str(nsheet)],'chromosoms'); if ~exist(nameFolder,'dir'); mkdir(nameFolder); end
                if thrType<3
                    nameFig=sprintf('%d%s.fig',idxVar,varName);
                    [significativas{idxVar},possorted]=showHists_v3(countings_G1{idxVar},countings_G2{idxVar},namegroups{idxVar},selectedVar,valueFilter,nBins,B,CI,nameFig,'Hists (G1 vs. G2)',nameFolder);
                    significativas{idxVar}=significativas{idxVar}(possorted); namegroups{idxVar}=namegroups{idxVar}(possorted);
                    countings_G1{idxVar}=countings_G1{idxVar}(possorted,:); countings_G2{idxVar}=countings_G2{idxVar}(possorted,:);
                else
                    nameFig=sprintf('%d%sG1vsG2vsG3.fig',idxVar,varName); [significativas1{idxVar},possorted1,significativas2{idxVar},possorted2]=showHists_v4(countings_G1{idxVar},countings_G3{idxVar},countings_G2{idxVar},namegroups{idxVar},selectedVar,valueFilter,nBins,B,CI,nameFig,'Hists (G1 vs. G2 vs. G3)',nameFolder);
                    countings_G1{idxVar}=countings_G1{idxVar}(possorted1,:); countings_G31{idxVar}=countings_G3{idxVar}(possorted1,:);
                    significativas1{idxVar}=significativas1{idxVar}(possorted1); namegroups1{idxVar}=namegroups{idxVar}(possorted1);
                    countings_G2{idxVar}=countings_G2{idxVar}(possorted2,:); countings_G32{idxVar}=countings_G3{idxVar}(possorted2,:);
                    significativas2{idxVar}=significativas2{idxVar}(possorted2); namegroups2{idxVar}=namegroups{idxVar}(possorted2);
                end
            elseif t.Data{12,idxVar}
                %%%%%%%%%%% VARIABLES NUMERICAS %%%%%%%%%%%
                namegroups{idxVar}={varName}; varnames{idxVar}=varName;
                if length(numericFiltering)>=idxVar; numericFilt=numericFiltering{idxVar}; else; numericFilt={}; end
                if length(trsFnc)>=idxVar; trsFunc=trsFnc{idxVar}; else; trsFunc={}; end; if ~isempty(trsFunc) && strcmp(trsFunc{1},''); trsFunc={}; end
                if t.Data{13,cell2mat(t.Data(18,:))}; thrFnc=dateFuncs{selectedDateTypes{cell2mat(t.Data(18,:))}{1}}; else; thrFnc=[]; end
                [countings,significativs]= histdiffmean_MR_v2(dss{nsheet},thresholdVar,threshold,selectedVar,filteringVar,valueFilter,numericFilt,nBins,thrFnc,trsFunc,CI);
                countings_G1{idxVar}=countings(1); countings_G2{idxVar}=countings(2);
                if length(countings)==4; countings_G31{idxVar}=countings(3); countings_G32{idxVar}=countings(4); significativas1{idxVar}=significativs{1}; significativas2{idxVar}=significativs{2}; namegroups1{idxVar}=namegroups{idxVar}; namegroups2{idxVar}=namegroups{idxVar}; 
                else; significativas{idxVar}=significativs; 
                end
                set(infoTxt,'String',['Please, wait... showing computed histograms of ',selectedVar,'...']); drawnow;
            elseif t.Data{13,idxVar}
                %%%%%%%%%%%%% VARIABLES FECHA %%%%%%%%%%%%%
                if length(selectedDateTypes)<idxVar || isempty(selectedDateTypes{idxVar}); infoTxt.String=['Please, select a Group Date (from 1 to 5) in ',varName,' variable']; drawnow; return; end
                if t.Data{13,cell2mat(t.Data(18,:))}; thrFnc=dateFuncs{selectedDateTypes{cell2mat(t.Data(18,:))}{1}}; else; thrFnc=[]; end
                significativs={};
                for idt=1:length(selectedDateTypes{idxVar})
                    idxType=selectedDateTypes{idxVar}{idt};
                    dateType=dateTypes{idxType};
                    varNameDate=[varName,'_',dateType]; varnames{idxVar}{idxType}=varNameDate;
                    kv_counts = histcountsDate_MR(dss{nsheet},idxVar,dateType);
                    groupNames=kv_counts.Key;
                    [countings_G1{idxVar}{idxType},countings_G2{idxVar}{idxType},countings_G3{idxVar}{idxType},namegroups{idxVar}{idxType}]...
                        = histmultiDate_MR_v2(dss{nsheet},thresholdVar,threshold,selectedVar,groupNames,filteringVar,valueFilter,nBins,dateType,thrFnc);
                    set(infoTxt,'String',['Please, wait... showing computed histograms of ',varNameDate,'...']); drawnow;
                    nameFolder=fullfile(pathToFigs,['Sheet',num2str(nsheet)],'chromosoms'); if ~exist(nameFolder,'dir'); mkdir(nameFolder); end
                    if thrType<3
                        nameFig=fullfile(nameFolder,sprintf('%d_%s.fig',idxVar,varNameDate));
                        [significativs{idt},possorted]=showHists_v3(countings_G1{idxVar}{idxType},countings_G2{idxVar}{idxType},groupNames,varNameDate,valueFilter,nBins,B,CI,nameFig,'Hists (G1 vs. G2)',nameFolder);
                        significativs{idt}=significativs{idt}(possorted); namegroups{idxVar}{idxType}=namegroups{idxVar}{idxType}(possorted);
                        countings_G1{idxVar}{idxType}=countings_G1{idxVar}{idxType}(possorted,:); countings_G2{idxVar}{idxType}=countings_G2{idxVar}{idxType}(possorted,:);
                    else
                        nameFig=fullfile(nameFolder,sprintf('%d_%s_G1vsG2vsG3.fig',idxVar,varName)); [significativs1{idt},possorted1,significativs2{idt},possorted2]=showHists_v4(countings_G1{idxVar}{idxType},countings_G3{idxVar}{idxType},countings_G2{idxVar}{idxType},namegroups{idxVar}{idxType},selectedVar,valueFilter,nBins,B,CI,nameFig,'Hists (G1 vs. G2 vs. G3)',nameFolder);
                        countings_G1{idxVar}{idxType}=countings_G1{idxVar}{idxType}(possorted1,:); countings_G31{idxVar}{idxType}=countings_G3{idxVar}{idxType}(possorted1,:);
                        significativs1{idt}=significativs1{idt}(possorted1); namegroups1{idxVar}{idxType}=namegroups{idxVar}{idxType}(possorted1);
                        countings_G2{idxVar}{idxType}=countings_G2{idxVar}{idxType}(possorted2,:); countings_G32{idxVar}{idxType}=countings_G3{idxVar}{idxType}(possorted2,:);
                        significativs2{idt}=significativs2{idt}(possorted2); namegroups2{idxVar}{idxType}=namegroups{idxVar}{idxType}(possorted2);
                        % % G1 vs. G3 (Top vs. Normal)
                        % nameFig=fullfile(nameFolder,sprintf('%d_%s_G1vsG3.fig',idxVar,varName));
                        % [significativs1{idt},possorted]=showHists_v3(countings_G1{idxVar}{idxType},countings_G3{idxVar}{idxType},groupNames,varNameDate,valueFilter,nBins,B,CI,nameFig,'Hists (Top vs. Normal)');
                        % significativs1{idt}=significativs1{idt}(possorted); namegroups1{idxVar}{idxType}=namegroups{idxVar}{idxType}(possorted);
                        % countings_G1{idxVar}{idxType}=countings_G1{idxVar}{idxType}(possorted,:); countings_G31{idxVar}{idxType}=countings_G3{idxVar}{idxType}(possorted,:);
                        % % G2 vs. G3 (Low vs. Normal)
                        % nameFig=fullfile(nameFolder,sprintf('%d_%s_G2vsG3.fig',idxVar,varName));
                        % [significativs2{idt},possorted]=showHists_v3(countings_G2{idxVar}{idxType},countings_G3{idxVar}{idxType},groupNames,varNameDate,valueFilter,nBins,B,CI,nameFig,'Hists (Small vs. Normal)');
                        % significativs2{idt}=significativs2{idt}(possorted); namegroups2{idxVar}{idxType}=namegroups{idxVar}{idxType}(possorted);
                        % countings_G2{idxVar}{idxType}=countings_G2{idxVar}{idxType}(possorted,:); countings_G32{idxVar}{idxType}=countings_G3{idxVar}{idxType}(possorted,:);
                    end
                end
                if thrType<3; significativas{idxVar}=significativs;
                else; significativas1{idxVar}=significativs1; significativas2{idxVar}=significativs2;
                end
            elseif t.Data{14,idxVar}
                %%%%%%%%%% VARIABLES TEXTO %%%%%%%%
                kv_bow = bow_MR(dss{nsheet},idxVar);
                groupNames=kv_bow.Key(cell2mat(kv_bow.Value)>thminrep);
                if t.Data{13,cell2mat(t.Data(18,:))}; thrFnc=dateFuncs{selectedDateTypes{cell2mat(t.Data(18,:))}{1}}; else; thrFnc=[]; end
                kv_counts = bowDiffProps_MR_v2(dss{nsheet},selectedVar,thresholdVar,threshold,groupNames,[],[],thrFnc);
                v=cat(1,kv_counts.Value{:});
                dictionary=kv_counts.Key;
                if size(v,2)<4
                    deltahist=cat(1,v{:,3})';
                    histbagG1=cat(1,v{:,1}); histbagG2=cat(1,v{:,2});
                    histbagG1=histbagG1/sum(histbagG1); histbagG2=histbagG2/sum(histbagG2);
                    set(infoTxt,'String',['Please, wait... showing computed histograms of ',selectedVar,'...']); drawnow;
                    deltaIC = miIC(deltahist,95);
                    idx=find(sign(deltaIC(2,:))==sign(deltaIC(3,:)));
                    significativs=false(1,size(deltaIC,2)); significativs(idx)=true;
                    pintaICs2(deltahist,deltaIC,dictionary,significativs)
                    dictionary=dictionary(idx); hists{idxVar}=[];
                    countings_G1{idxVar}=array2table(histbagG1(idx)');
                    countings_G2{idxVar}=array2table(histbagG2(idx)');
                    namegroups{idxVar}=dictionary;
                    % En el BOW solo se ponen las significativas en el chromosoma
                    significativas{idxVar}=significativs(idx);
                else
                    deltahist1=cat(1,v{:,4})'; deltahist2=cat(1,v{:,5})';
                    histbagG1=cat(1,v{:,1}); histbagG2=cat(1,v{:,2}); histbagG3=cat(1,v{:,3});
                    histbagG1=histbagG1/sum(histbagG1); histbagG2=histbagG2/sum(histbagG2); histbagG3=histbagG3/sum(histbagG3);
                    set(infoTxt,'String',['Please, wait... showing computed histograms of ',selectedVar,'...']); drawnow;
                    deltaIC1 = miIC(deltahist1,95); deltaIC2 = miIC(deltahist2,95);
                    idx=find(sign(deltaIC1(2,:))==sign(deltaIC1(3,:)));
                    significativs1=false(1,size(deltaIC1,2)); significativs1(idx)=true;
                    pintaICs2(deltahist1,deltaIC1,dictionary,significativs1)
                    dictionary1=dictionary(idx); hists{idxVar}=[];
                    countings_G1{idxVar}=array2table(histbagG1(idx)');
                    countings_G31{idxVar}=array2table(histbagG3(idx)');
                    idx=find(sign(deltaIC2(2,:))==sign(deltaIC2(3,:)));
                    significativs2=false(1,size(deltaIC2,2)); significativs2(idx)=true;
                    pintaICs2(deltahist2,deltaIC2,dictionary,significativs2)
                    dictionary2=dictionary(idx); hists{idxVar}=[];
                    countings_G2{idxVar}=array2table(histbagG2(idx)');
                    countings_G32{idxVar}=array2table(histbagG3(idx)');
                    namegroups1{idxVar}=dictionary1; namegroups2{idxVar}=dictionary2;
                    % En el BOW solo se ponen las significativas en el chromosoma
                    significativas1{idxVar}=significativs1(idx); significativas2{idxVar}=significativs2(idx);
                end
                varnames{idxVar}=varName;
            else
                continue
            end
        end
        pathToResults=fullfile(pathToData,caso,'results');
        if exist(pathToResults,'dir')==0; mkdir(pathToResults); end
        if thrType<3
            showChromosomes_v5(countings_G1,countings_G2,namegroups,varnames,significativas,'Chromosoms (G1 vs. G2)',pathToResults)
            disp('G1: left side of threshold'); disp('G2: right side of threshold')
        else
            showChromosomes_v5(countings_G1,countings_G31,namegroups1,varnames,significativas1,'Chromosoms (G1 vs. G2)',pathToResults)
            showChromosomes_v5(countings_G2,countings_G32,namegroups2,varnames,significativas2,'Chromosoms (G3 vs. G2)',pathToResults)
            disp('G1: left side of the left threshold'); disp('G3: right side of the right threshold')
        end
        infoTxt.String='Done!';
    end
    function showHistThr(column_selected)
        set(infoTxt,'String','Please, wait... computing histogram of threshold variable...'); drawnow;
        if sum(cell2mat(t.Data(20,:)))>0 && cell2mat(t.Data(12,cell2mat(t.Data(20,:)))); idxAggrVar=cell2mat(t.Data(20,:)); aggregationVar=t.ColumnName{idxAggrVar}; else; aggregationVar=[]; end
        if exist('idxAggrVar','var') && length(numericFiltering)>=find(idxAggrVar); numericFilt=numericFiltering{idxAggrVar}; else; numericFilt={}; end
        if t.Data{13,column_selected}
            if length(selectedDateTypes{column_selected})~=1; infoTxt.String='Please, choose only one Group Date for threshold'; drawnow; return; end
            idxType=selectedDateTypes{column_selected}{1}; dateType=dateTypes{idxType};
            kv_counts = histcountsDate_MR(dss{nsheet},column_selected,dateType); if sum(strcmp(kv_counts.Key,'')); kv_counts.Key{strcmp(kv_counts.Key,'')}='NaN'; end
        else
            kv_counts = histcounts_MR_vAggr(dss{nsheet},column_selected,aggregationVar,numericFilt); if sum(strcmp(kv_counts.Key,'')); kv_counts.Key{strcmp(kv_counts.Key,'')}='NaN'; end
        end
        if t.Data{12,column_selected} % Si la variable es numérica 
            if iscell(kv_counts.Key); keys=cellfun(@(key) str2double(key),kv_counts.Key); else; keys=kv_counts.Key; end
            posnan=find(isnan(keys)); if ~isempty(posnan); keys(posnan)=[]; kv_counts.Value{posnan}=[]; end
            [keys,pos]=sort(keys,'ascend'); val=cat(1,kv_counts.Value{:}); val=val(pos);
        else
            [val,pos]=sort(cat(1,kv_counts.Value{:}),'descend'); keys=kv_counts.Key(pos);
            if ~isempty(ts{2}.Data) && t.Data{18,column_selected} && t.Data{19,column_selected} % Si la variable filtrado es la misma que la del umbral
                valueFilter=ts{2}.Data(cell2mat(ts{2}.Data(:,1)),2); posFiltered=ismember(keys,valueFilter); keys(~posFiltered)=[]; val(~posFiltered)=[];
            %elseif ~isempty(ts{2}.Data) && t.Data{18,column_selected} && any(cat(1,t.Data{19,:})) % Si la variable filtrada es distinta que la del umbral y se seleccionó antes la de filtrado
            end
        end
        porcs{1}=cumsum(val/sum(val)*100); porcs{2}=keys;
        if t.Data{11,column_selected} || t.Data{13,column_selected} % Si es categorica o fecha
            if iscell(keys); keys=arrayfun(@(x,y) [x{1},' (',num2str(y,'%.1f'),'%)'],keys,porcs{1},'UniformOutput',false);
            else; keys=arrayfun(@(x,y) [num2str(x),' (',num2str(y,'%.1f'),'%)'],keys,porcs{1},'UniformOutput',false);
            end
            aaxx=plotyy(axs{1},1:length(val),val,1:length(val),porcs{1},@bar,@plot); ylabel(aaxx(1),'Histogram'); ylabel(aaxx(2),'Cumulative distribution (%)')
            lkeys=length(keys); if lkeys>60; for ipos=1:10; [~,posk(ipos)]=min(abs(porcs{1}-ipos*10)); end; posk=unique(posk); keys=keys(posk); xticks=posk; else; xticks=1:lkeys; end; if iscell(keys); set(axs{1},'XTick',xticks); set(axs{1},'XTickLabel',keys); else; keys=arrayfun(@(x) {num2str(x)},keys); set(axs{1},'XTick',xticks); set(axs{1},'XTickLabel',keys); end; xtickangle(axs{1},45)
            isNumericalThr=false;
        else
            %bar(axs{1},val);
            aaxx=plotyy(axs{1},1:length(val),val,1:length(val),porcs{1},@bar,@plot); ylabel(aaxx(1),'Histogram'); ylabel(aaxx(2),'Cumulative distribution (%)')
            lkeys=length(keys); if lkeys>60; for ipos=1:10; [~,posk(ipos)]=min(abs(porcs{1}-ipos*10)); end; keys=keys(posk); xticks=posk; else; xticks=1:lkeys; end; if iscell(keys); set(axs{1},'XTick',xticks); set(axs{1},'XTickLabel',keys); else; keys=arrayfun(@(x) {num2str(x)},keys); set(axs{1},'XTick',xticks); set(axs{1},'XTickLabel',keys); end; xtickangle(axs{1},45)
            isNumericalThr=true;%porcs={};
        end
        threshold=NaN; inputs{1}.String=['Group 1 (G1) <= ',num2str(threshold)]; axis tight
        Cs{2}.Visible='on';
        set(infoTxt,'String','Please, write a desired threshold in the edit field... e.g. Group 1 (G1) <= 2... and press ENTER'); drawnow;
    end
    function FChooseTypeThreshold(source,~)
        thrType=source.Value-1;
        if thrType==0; thrType=1; return; end
        if thrType==1; inputs{1}.Position(3)=.09; inputs{1}.String='Group 1 (G1) <= XXX'; end
        if thrType==2; inputs{1}.Position(3)=.15; inputs{1}.String='Group 1 (G1) <= XXX'; end
        if thrType==3; inputs{1}.Position(3)=.2; inputs{1}.String='G1 <= XXX < G2 <= YYY < G3'; end
        setThreshold();
    end
    function FInputThr(source,~)
        numThreshold=cellfun(@str2num,getNumbers(source.String));
        if thrType<3; numThreshold=numThreshold(end); else; numThreshold=numThreshold([2 4]); end
        setThreshold();
    end
    function setThreshold()
        if isempty(numThreshold); return; end
        if thrType==3 && length(numThreshold)<2; inputs{1}.String='G1 <= XXX < G2 <= YYY < G3'; infoTxt.String='Please, write XXX and YYY thresholds in the edit field and press ENTER'; return; end
        threshold=numThreshold;
        if thrType==3
            [~,pos]=min(abs(porcs{1}-numThreshold(1))); threshold(1)=porcs{1}(pos);
            [~,pos2]=min(abs(porcs{1}-numThreshold(2))); threshold(2)=porcs{1}(pos2); threshold(3)=porcs{1}(end);
            inputs{1}.String=sprintf('G1 <= %.2f < G2 <= %.2f < G3',threshold(1),threshold(2));
        else
            if ~isNumericalThr || thrType==2; [~,pos]=min(abs(porcs{1}-numThreshold(1))); threshold(1)=porcs{1}(pos); end
            inputs{1}.String=sprintf('Group 1 (G1) <= %.2f',threshold(1));
            if thrType==2
                [~,pos2]=min(abs(porcs{1}(end)-porcs{1}-numThreshold(1))); threshold(2)=porcs{1}(pos2);
                inputs{1}.String=sprintf('%s and >= %.2f',threshold(1),threshold(2));
            end
        end
        infoTxt.String=['Threshold var fixed in order to ',inputs{1}.String];
        if ~isNumericalThr; inputs{1}.String=[inputs{1}.String,'%']; thrs{1}=porcs{2}(1:pos); if thrType>=2; thrs{2}=porcs{2}(pos2+1:end); end; if thrType==3; thrs{3}=porcs{2}(pos+1:pos2); end; threshold=thrs; end
        if isNumericalThr; threshold=numThreshold(1); end %threshold=[porcs{2}(pos), porcs{2}(pos2)]; end
        linesThr=findobj(axs{1},'Color','r'); if ~isempty(linesThr); delete(linesThr); end
        if ~isNumericalThr || thrType>=2
            axs{1}; hold on; plot([pos+.5 pos+.5],ylim,'r-'); % Se dibuja el umbral
            if thrType>=2; plot([pos2+.5 pos2+.5],ylim,'r-'); end; hold off;
            if thrType>=2 && pos==pos2; infoTxt.String='Sorry, same thresholds -> Group 1 would correspond to all cases... Please, choose new valid thresholds'; return; end
        end
    end
    function getCI(source,~); CI=cellfun(@str2num,getNumbers(source.String)); CI=CI(end); inputs{2}.String=sprintf('CI: %.1f%%',CI); end
    function fillingListBox(varGroupType,column_selected)
        set(infoTxt,'String','Please, wait... unique categories are being obtained...'); drawnow;
        if strcmp(varGroupType,'Filtering'); ttype=2; else; ttype=1; end
        if ~t.Data{11,column_selected} && ~t.Data{13,column_selected}; set(infoTxt,'String','Sorry, this variable has to be categorical or datetime'); drawnow; return; end
        kv_counts = histcounts_MR(dss{nsheet},column_selected);
        [val,pos]=sort(cat(1,kv_counts.Value{:}),'descend'); key_sorted=kv_counts.Key(pos);
        ts{ttype}.Visible='on'; ts{ttype}.ColumnName={'Selection';'Key';'Count'}; ts{ttype}.ColumnEditable=true;
        if ~iscell(key_sorted); key_sorted=num2cell(key_sorted); end
        if t.Data{18,column_selected}; checks=num2cell(true(size(val))); else; checks=num2cell(false(size(val))); end % Se seleccionan todos si se trata de la variable umbral
        ts{ttype}.Data=[checks,key_sorted,num2cell(val)];
        set(infoTxt,'String','Ready'); drawnow;
    end
    function bivariate(); ok{2}.Visible='on'; ok{2}.Callback=@getBivariate; ok{2}.String='Get bivariate!'; end
    function getBivariate(~,~)
        datatypes={}; varNames=cell(1,2);
        selectedVars=find(cell2mat(t.Data(17,:)));
        if isempty(selectedVars); infoTxt.String='Please, choose the variables you want to analyze in "Selected vars."'; drawnow; return; end
        % SE COMPRUEBA QUE SE INDICAN BIEN LAS VARIABLES A COMPARAR Y SE RECONOCE CADA TIPO DE VARIABLE PARA PASARLO A LA FUNCION MR
        if length(selectedVars)>2; infoTxt.String='Please, select only two variables to compare... thanks'; return; end
        % Si las dos variables a comparar son dos tipos de fechas de una misma variable
        if length(selectedVars)==1
            if length(t.Data(13,selectedVars))==1 && (length(selectedDateTypes)<selectedVars || length(selectedDateTypes{selectedVars})~=2); infoTxt.String='Please, select two date types to compare... thanks'; return; end
            datatypes={dateTypes{selectedDateTypes{selectedVars}{1}}, dateTypes{selectedDateTypes{selectedVars}{2}}};
            for iv=1:length(varNames); varNames{iv}=[t.ColumnName{selectedVars(iv)},'-',datatypes{iv}]; end
            % Si las dos variables a comparar son de tipo fecha
        elseif length(selectedVars)==2 && t.Data{13,selectedVars(1)} && t.Data{13,selectedVars(2)}
            if length(selectedDateTypes{selectedVars(1)})~=1 || length(selectedDateTypes{selectedVars(1)})~=1; infoTxt.String='There are two datetime vars. Please, select only one date type for each datetime variable... thanks'; return; end
            datatypes={dateTypes{selectedDateTypes{selectedVars(1)}{1}}, dateTypes{selectedDateTypes{selectedVars(2)}{1}}};
            for iv=1:length(varNames); varNames{iv}=[t.ColumnName{selectedVars(iv)},'-',datatypes{iv}]; end
            % Si alguna de las seleccionadas es texto... por ahora no se aplica
        elseif t.Data{14,selectedVars(1)} || t.Data{14,selectedVars(2)}; infoTxt.String='Text variables are not yet allowed in this bivariate analysis...'; return;
            % Si las dos vars son numericas... aun no contemplado
        elseif t.Data{12,selectedVars(1)} && t.Data{12,selectedVars(2)}; infoTxt.String='Two numeric vars case is not yet allowed in this bivariate analysis...'; return;
        else
            % Si alguna de las seleccionadas es datetime con ~=1 datetypes
            if t.Data{13,selectedVars(1)} || t.Data{13,selectedVars(2)}
                posdatetime=find(cat(1,t.Data{13,selectedVars}));
                if length(selectedDateTypes)<selectedVars(posdatetime) || length(selectedDateTypes{selectedVars(posdatetime)})~=1; infoTxt.String='Only one date type is allowed for the selected datetime var...'; return; end
                datatypes{posdatetime}=dateTypes{selectedDateTypes{selectedVars(posdatetime)}{1}};
                varNames{posdatetime}=[t.ColumnName{selectedVars(posdatetime)},'-',datatypes{posdatetime}];
            end
            % Se incluyen los tipos de datos categoricos o numericos
            for iv=1:length(selectedVars)
                if t.Data{11,selectedVars(iv)}; datatypes{iv}='Cat';
                elseif t.Data{12,selectedVars(iv)}; datatypes{iv}='Num';
                end
                if isempty(varNames{iv}); varNames{iv}=t.ColumnName{selectedVars(iv)}; end
            end
        end
        infoTxt.String='Please, wait... computing bivariate analysis...'; drawnow;
        kv_counts = histcountsBivariate_MR(dss{nsheet},selectedVars,datatypes);
        b=@(x) strsplit(x,'_'); c=cellfun(b,kv_counts.Key,'UniformOutput',false); d=cat(1,c{:});
        x1=unique(d(:,1)); f1=@(x) find(strcmp(x,x1)); pos1=cellfun(f1,d(:,1));
        x2=unique(d(:,2)); f2=@(x) find(strcmp(x,x2)); pos2=cellfun(f2,d(:,2));
        for ipv=1:length(pos1); X(pos1(ipv),pos2(ipv))=kv_counts.Value{ipv}; end
        infoTxt.String='Done';
        figure; bar3(X); set(gca,'XTick',1:length(x2)); set(gca,'XTickLabel',x2); set(gca,'YTick',1:length(x1)); set(gca,'YTickLabel',x1); xlabel(varNames{2}); ylabel(varNames{1}); axis square
        nameFolder=fullfile(pathToFigs,['Sheet',num2str(nsheet)]); if ~exist(nameFolder,'dir'); mkdir(nameFolder); end
        nameFig=fullfile(nameFolder,sprintf('Bivar_%s_vs_%s.fig',varNames{1},varNames{2}));
        savefig(nameFig);
    end
    function exportMatrices(); ok{2}.Visible='on'; ok{2}.Callback=@exportXY; ok{2}.String='Export dataset!'; end
    function exportXY(~,~)
        selectedVars=find(cell2mat(t.Data(17,:)));
        if isempty(selectedVars); infoTxt.String='Please, choose the variables you want to export as X matrix in "Selected vars."'; drawnow; return; end
        supervisedVars=find(cell2mat(t.Data(23,:)));
        if isempty(supervisedVars); infoTxt.String='Please, choose the variables you want to export as Y matrix in "Supervised vars."'; drawnow; return; end
        infoTxt.String='Creating new dataset to export... Please, wait...'; drawnow
        varnames=dss{nsheet}.SelectedVariableNames;
        dss{nsheet}.SelectedVariableNames=varnames(selectedVars);
        while ~exist('X','var')
            if isprop(dss{nsheet},'SelectedVariableTypes'); types=dss{nsheet}.SelectedVariableTypes;
            else; types=dss{nsheet}.SelectedFormats;
            end
            ttt=tall(dss{nsheet});
            posDatetime=find(cat(1,t.Data{13,selectedVars}));
            for idt=1:length(posDatetime)
                datetypes=selectedDateTypes{selectedVars(posDatetime(idt))};
                for jdt=1:length(datetypes)
                    newnamevar=[varnames{selectedVars(posDatetime(idt))},'_',dateTypes{datetypes{jdt}}];
                    ttt.(newnamevar)=dateFuncs{datetypes{jdt}}(ttt.(varnames{selectedVars(posDatetime(idt))}));
                    Xformat.(newnamevar)='char';
                end
                ttt.(varnames{selectedVars(posDatetime(idt))})=[];
            end
            posOtherTypes=find(~cat(1,t.Data{13,selectedVars}));
            for iot=1:length(posOtherTypes)
                namevar=varnames{selectedVars(posOtherTypes(iot))};
                Xformat.(namevar)=strrep(strrep(strrep(types{posOtherTypes(iot)},'%q','char'),'%f','double'),'%s','string');
            end
            try
                X=gather(ttt);
            catch ME
                if (strcmp(ME.identifier,'MATLAB:bigdata:array:ExecutionError'))
                    parts=strsplit(ME.message,''''); disp(['Converting format from numeric to char in var. ',parts{2},'...'])
                    dss{nsheet}.SelectedVariableTypes{strcmp(dss{nsheet}.SelectedVariableNames,parts{2})}='char';
                else
                    rethrow(ME)
                end
            end
        end; clear ttt;
        dss{nsheet}.SelectedVariableNames=varnames(supervisedVars);
        while ~exist('Y','var')
            if isprop(dss{nsheet},'SelectedVariableTypes'); types=dss{nsheet}.SelectedVariableTypes;
            else; types=dss{nsheet}.SelectedFormats;
            end
            ttt=tall(dss{nsheet});
            posDatetime=find(cat(1,t.Data{13,supervisedVars}));
            for idt=1:length(posDatetime)
                datetypes=selectedDateTypes{supervisedVars(posDatetime(idt))};
                for jdt=1:length(datetypes)
                    newnamevar=[varnames{supervisedVars(posDatetime(idt))},'_',dateTypes{datetypes{jdt}}];
                    ttt.(newnamevar)=dateFuncs{datetypes{jdt}}(ttt.(varnames{supervisedVars(posDatetime(idt))}));
                    Yformat.(newnamevar)='char';
                end
                ttt.(varnames{supervisedVars(posDatetime(idt))})=[];
            end
            posOtherTypes=find(~cat(1,t.Data{13,supervisedVars}));
            for iot=1:length(posOtherTypes)
                namevar=varnames{supervisedVars(posOtherTypes(iot))};
                Yformat.(namevar)=strrep(strrep(strrep(types{posOtherTypes(iot)},'%q','char'),'%f','double'),'%s','string');
            end
            try
                Y=gather(ttt);
            catch ME
                if (strcmp(ME.identifier,'MATLAB:bigdata:array:ExecutionError'))
                    parts=strsplit(ME.message,''''); disp(['Converting format from numeric to char in var. ',parts{2},'...'])
                    dss{nsheet}.SelectedVariableTypes{strcmp(dss{nsheet}.SelectedVariableNames,parts{2})}='char';
                else
                    rethrow(ME)
                end
            end
        end; clear ttt;
        dss{nsheet}.SelectedVariableNames=varnames; % Reset dss
        [file,path] = uiputfile('*.mat','Save as',fullfile(pathToData,caso,[caso,'.mat']));
        save(fullfile(path,file),'X','Y','Xformat','Yformat')
    end

%% Visualization functions
    function showHistIndividuals(almacenI,axes1,axes2,idxVar,typeData,typeDate,figure_number)
        if nargin<6; typeDate=''; end
        varName=t.ColumnName{idxVar}; if ~isempty(typeDate); varName=[varName,'_',typeDate]; end
        for ia1=1:length(axes1)
            if nargin<7; figure, clf; else; figure(figure_number*100+ia1); clf; end
            for ia2=1:length(axes2)
                n = almacenI{ia1,ia2};
                b = 1:length(n);
                plot3(ia2*ones(size(b)),b,n,'.-');
                hold on
            end
            hold off, axis tight, xticks(1:length(axes2)), xticklabels(axes2),
            if typeData==2
                ylabel('sorted samples'); zlabel(strrep(varName,'_',' '));
            else
                zlabel('# occurrence'); ylabel(strcat('#',strrep(varName,'_',' ')));
            end
            title(axes1{ia1}); if isempty(axes1{1}); view([-90 0]); end
            nameFolder=fullfile(pathToFigs,['Sheet',num2str(nsheet)]);
            if ~exist(nameFolder,'dir'); mkdir(nameFolder); end
            nameFig=fullfile(nameFolder,sprintf('%d_%s_%s.fig',idxVar,varName,axes1{ia1}));
            savefig(nameFig);
        end
    end
end
