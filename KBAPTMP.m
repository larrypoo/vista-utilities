KBAPTMP ;ven/lgc - Pull checksums from KIDS and docker ; 5/14/19 12:40pm
 ;;18.0;SAMI;;
START(filename) ;
 set path="/home/osehra/"
 do OPEN^%ZISH("FILE",path,filename,"R")
 new line
 for  use IO read line:1 quit:$$STATUS^%ZISH  do
 . U $P write !,line
 quit
 do CLOSE^%ZISH
 quit
 ;
LIST(ien) ;
 new cnt kill POO
 quit:'$d(^%wd(17.040801,ien))
 set node=$na(^%wd(17.040801,ien)),snode=$p(node,")")
 for  s node=$Q(@node) q:node'[snode  d
 .; write !,$p(node,",",2,7),"=",@node
 . write !,$p(node,",",2)_"^"_$p(node,",",3)_"^"_$p(node,",",4)
 . write "^"_$p(node,",",5)_"^"_$p(node,",",6)_"^"_$p(node,",",7)
 . write "^=^"_@node
 .; set cnt=$get(cnt)+1
 .; set POO(cnt)=$p(node,",",2,7)_"="_@node
 quit
