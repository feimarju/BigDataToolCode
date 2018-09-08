function str = replaceCharsbySpace(str)

% [ ] , . ( ) - /
chars_old = [char(40),char(41),char(44),char(46),char(91),char(93),char(45),char(47)];
chars_new = '        ';
[tf,loc] = ismember(str, chars_old);
str(tf) = chars_new(loc(tf));