function str = removeAccents(str)

chars_old = [char(0193),char(0225),char(0201),char(0233),char(0205),char(0237),char(0211),char(0243),char(0218),char(0250),char(0209),char(0241),char(63),char(32)];
chars_new = 'AaEeIiOoUuNn__';
[tf,loc] = ismember(str, chars_old);
str(tf) = chars_new(loc(tf));
