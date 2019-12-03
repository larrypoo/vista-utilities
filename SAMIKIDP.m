SAMIKIDP ;ven/lgc - SAMI KIDS POST INSTALL ;Dec 03, 2019@09:05
 ;SAMI V18.0;;;;
 ;
 quit  ; no entry from top
 ;
 ;
 ; In order to simplify pulling the graphs in the VAPALS
 ;   graph file into a KIDS, load everything from the
 ;   ^%wd global [graph file] into a conventional single
 ;   field file.  A post install routine will pull the
 ;   information out and rebuild the ^%wd global
BLDKBAP ; Fill entries in ^KBAP(11312013 with all entries in ^%wd global
 ;@input
 ; KBAP SAMI KIDS [#11312013] file exists in environment
 ; graph [#17.040801] file graphs exist in environment
 ;@output
 ; KBAP SAMI KIDS loaded with all entries from
 ;   the graph file
 ;
 ; empty receiving file
 new I set I=$O(^KBAP(11312013,"A"),-1)
 S DIK="^KBAP(11312013," F DA=I:-1:1 D ^DIK
 ;
 ; Run down every node in the ^%wd graph global and
 ;   save in KBAP SAMI KIDS
 ; NOTE: do not save data in the "fhir-intake" graph
 ;   but just save the zero node.
 n node,snode,cnt,stop
 s stop=0
 set node=$na(^%wd(17.040801)),snode=$piece(node,")")
 for  set node=$Q(@node) do  q:stop
 . if node'[snode s stop=1
 . quit:stop
 . if ($qs(node,2)=13),'($qs(node,3)=0) quit
 . set cnt=$g(cnt)+1
 . set ^KBAP(11312013,cnt,0)=node
 . set ^KBAP(11312013,cnt,1)=@node
 quit
 ;
 ;
 ; Build the VAPALS graphs into ^%wd(17.040801 from
 ;  the entries in the KBAP SAMI KIDS file
 ; Once successfully completed the KBAP SAMI KIDS
 ;  file may be deleted.
BLDWDG ; Build ^%wd graphs from KBAP SAMI KIDS
 ;@input
 ;   KBAP SAMI KIDS file [^KBAP(11312013] loaded
 ;     with all nodes from the graph [#17.040801] file
 ;@output
 ;   graph [#17.040801] built in ^%wd
 ;
 ; save existing ^%wd(17.040801 global in case it
 ;  is necessary to back out this rebuild
 kill ^KBAP("graph")
 merge ^KBAP("graph")=^%wd(17.040801)
 ;
 new node,snode,gbl,data
 set node=$na(^KBAP(11312013)),snode=$piece(node,")")
 set node=$Q(@node)
 for  set node=$Q(@node) q:(node'[snode)  do
 . if ($qs(node,3)=0) s glb=@node quit
 . if ($qs(node,3)=1) s data=@node do
 .. s @glb=data
 ;
 ; now rebuild "B" cross reference
 set DIK="^%wd(17.040801,"
 do IXALL2^DIK  ; delete all cross-references ("B")
 do IXALL^DIK  ; set all cross-references ("B")
 quit
 ;
 ;
 ; MASH routines reside in the % namespace which, is not
 ;   allowed in a KIDS build. Thus we need to pull the
 ;   MASH routines used by VAPALS into conventionally
 ;   named routines so they may be transfered in a KIDS
 ; A post install routine will copy these out into the
 ;   % routines expected by VAPALS following successful
 ;   installation of the KIDS.
BLDRTNS ; Build new routines from MASH so they can pass through KIDS
 ;@input
 ;  listing of MASH routines to be converted to ^KBAPZ*
 ;    routines (see linetag PRCNTR below)
 ;@output
 ;  new routines KBAPZ0,KBAPZ1 ... KBAPZn
 ;
 new cnt,file,path,rtnln,rtnarr
 s path="/home/osehra/run/routines/"
 s cnt=-1
 f  s cnt=($get(cnt)+1),file=$piece($text(PRCNTR+cnt^SAMIKIDP),";;",2) quit:(file["***END***")  do
 .; open file for reading
 . kill rtnarr
 . set rtnln=0
 . do OPEN^%ZISH("FILE",path,file,"R")
 . for  use IO read line:1 quit:$$STATUS^%ZISH  do
 .. set rtnln=rtnln+1,rtnarr(rtnln)=line
 . do CLOSE^%ZISH
 .;
DEBUG .; write !,! zwr rtnarr
 .;
 .; Open file for writing
 . set file="KBAPZ"_cnt_".m"
 . do OPEN^%ZISH("FILE",path,file,"W")
 . set rtnln=0
 . for  set rtnln=$o(rtnarr(rtnln)) q:'rtnln  d
 .. set line=rtnarr(rtnln)
 .. use IO write line,!
 . do CLOSE^%ZISH
 .;
 .; Now add to ROUTINE file so KIDS can load
 . new RTN set RTN=$piece(file,".")
 . do LOAD^XINDEX
 . set ^UTILITY($J,1,RTN,0)=RTN
 .; Load into ROUTINE file
 . do ^XINDX53
 .; and unload ^UTILITY
 . kill ^UTILITY($J,1,RTN)
 ;
 quit
 ;
 ;open file for writing (KBAPn.m) - where n=1,2,3...
 ;
PRCNTR ;;_wd.m
 ;;_wf.m
 ;;_thage.m
 ;;_th.m
 ;;***END***
 ;;
 ;
EOR ;End of routine SAMIKIDP
