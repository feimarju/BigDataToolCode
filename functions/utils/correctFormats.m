function [dss,dst] = correctFormats(dss,dst)

while ~istall(dst{1})
    try
        dst{1} = tall(dss{1});
    catch ME
        switch ME.identifier
            case 'MATLAB:textscan:handleErrorAndShowInfo'
                message=ME.cause{1}.message; parts=strsplit(message,'''');
                dss{1}.TextscanFormats{(strcmp(dss{1}.VariableNames,parts{2}))}='%q';
                warning(sprintf('Format of variable %s has been changed from ''%%f'' to ''%%q''',parts{2}))
            otherwise
                rethrow(ME)
        end
    end
end
ok=0;
while ~ok
    dst{1}
    [msgstr, msgid] = lastwarn;
    if strcmp(msgid,'MATLAB:bigdata:array:DisplayPreviewErrored')
        parts=strsplit(msgstr,'''');
        dss{1}.TextscanFormats{(strcmp(dss{1}.VariableNames,parts{6}))}='%q';
        dst{1} = tall(dss{1});
        warning(sprintf('Format of variable %s has been changed from ''%%f'' to ''%%q''',parts{6}))
    else
        ok=1;
    end
end