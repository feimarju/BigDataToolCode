function stopwords=load_stopwords(language)

if nargin<1; language='ES'; end

switch language
    case 'ES'
        stopwords={'algun','alguna','algunas','alguno','algunos','ambos','ampleamos','ante','antes','aquel','aquellas','aquellos','aqui','arriba','atras','bajo','bastante','bien','cada','cierta','ciertas','cierto','ciertos','como','con','conseguimos','conseguir','consigo','consigue','consiguen','consigues','cual','cuando','dentro','de','del','desde','donde','dos','el','ellas','ellos','empleais','emplean','emplear','empleas','empleo','en','encima','entonces','entre','era','eramos','eran','eras','eres','es','esta','estaba','estado','estais','estamos','estan','estoy','fin','fue','fueron','fui','fuimos','gueno','ha','hace','haceis','hacemos','hacen','hacer','haces','hago','incluso','intenta','intentais','intentamos','intentan','intentar','intentas','intento','ir','la','largo','las','lo','los','mientras','mio','modo','muchos','muy','nos','nosotros','otro','para','pero','podeis','podemos','poder','podria','podriais','podriamos','podrian','podrias','por','por que','porque','primero','puede','pueden','puedo','quien','sabe','sabeis','sabemos','saben','saber','sabes','ser','si','siendo','sin','sobre','sois','solamente','solo','somos','soy','su','sus','tambien','teneis','tenemos','tener','tengo','tiempo','tiene','tienen','todo','trabaja','trabajais','trabajamos','trabajan','trabajar','trabajas','trabajo','tras','tuyo','ultimo','un','una','unas','uno','unos','usa','usais','usamos','usan','usar','usas','uso','va','vais','valor','vamos','van','vaya','verdad','verdadera','verdadero','vosotras','vosotros','voy','yo','y','a','ante','bajo','cabe','con','contra','de','desde','en','entre','hacia','hasta','para','por','segun','sin','so','sobre','tras'};
    otherwise
        stopwords={};
        warning('Language %s has not yet been contemplated... Empty stopwords is returned.')
end
