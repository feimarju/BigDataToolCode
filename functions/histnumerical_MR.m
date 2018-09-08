function kv_counts=histnumerical_MR(ds,nvar,numericFiltering,trsFnc)

myNames = ds.VariableNames;
ds.SelectedVariableNames = myNames{nvar};
varName = myNames{nvar};

outds = mapreduce(ds,...
    @(data,info,kvs)BinsMapFun(data,info,kvs,varName,[],numericFiltering,trsFnc),...
    @BinsReduceFun);
kv_result0 = readall(outds);
vmax=max(kv_result0.Value{2}); vmin=min(kv_result0.Value{1}); IQR=median(kv_result0.Value{3}); n=kv_result0.Value{4};
h=2*IQR/n^(1/3); nbins=min(1000,(vmax-vmin)/h); binsGroups=linspace(vmin,vmax,nbins);

outds = mapreduce(ds,@(data,info,kvs)MultiNumHistMapFun(data,info,kvs,...
    varName,[],numericFiltering,trsFnc,binsGroups),@MultiNumHistReduceFun);

kv = readall(outds);
sums = kv.Value{1};
n=sum(sums(:,2)); probs=sums(:,2)/n; means=sums(:,1)./sums(:,2); posNaNs=isnan(means); probs(posNaNs)=[]; means(posNaNs)=[];
kv_counts.means=means;
kv_counts.probs=probs;

ds.SelectedVariableNames = myNames; % se resetea la variables seleccionadas
delete result_r*.mat % se eliminan los ficheros intermedios generados
