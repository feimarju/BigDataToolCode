function showHistsGroups(histsgroups,nameVar,valueFilter,nameFig)

nameVar=strrep(nameVar,'_',' ');
figure;  histogram('BinEdges',histsgroups.edges,'BinCounts',histsgroups.histG1,'Normalization','pdf')
hold on; histogram('BinEdges',histsgroups.edges,'BinCounts',histsgroups.histG2,'Normalization','pdf')
legend('G1 (left side of threshold)','G2 (right side of threshold)')
title([nameVar, ' ', valueFilter]);
xlabel(nameVar)
if nargin==4 && ischar(nameFig); savefig(nameFig); end