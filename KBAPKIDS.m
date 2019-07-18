KBAPKIDS ;ven/lgc - Semi-automated KIDS install ; 7/18/19 2:58am
 ;;18.0;SAMI;;
 ;
 quit  ; no entry from top
 ;
 ;
START ; Prepare to install patches for a package
 ; new pgkarr
 n success,chksmok
 do PKG^KBAPKIDS(.pkgarr)
 quit:'$data(pkgarr)
 do LASTPTCH^KBAPKIDS(.pkgarr)
 do NXTPATCH^KBAPKIDS(.pkgarr)
 ;
 ; if no more patches, bail
 ;
 if (pkgarr("nextpatch")="none") do  quit
 . write !,!,"*** All released patches installed ***",!,!
 ;
 ; Bring files into the ~/KIDS director
 ;  and build the .CKS checksum file
 ;  success may contain
 ;           k = found kids
 ;           t = found associated text file
 ;           n = 0 no checksum errors, 1 = checksum errors
GETKIDS set success=$$PULLKIDS^KBAPKIDS(.pkgarr)
 ;
 write !,!,"success=",success,!,!
 ;
 if success["k",success["t",success["0" do  quit
LOAD . do START^KBAPXPDL(.pkgarr) ; load KIDS
BACKUP . do START^KBAPXPDB(.pkgarr) ; backup KIDS
INSTALL . do START^KBAPXPDI(.pkgarr) ; install KIDS
 ;
 ; Generate post install checksums
 ; need the name of the .CKS file in filename
 ;set success=$$POSTICHK^KBAPKID1(path,filename)
 ;if success["1" w !,!,"*** Post Install checksum Failure ***",!,!
 ;else  d
 ; write !,!,"Post Install Checksums Correct",!,!
 ;
 ;write !,!,"*** Patch Install FAILED ***",!,!
 quit
 ;
 ;
 ;@ppi
PKG(pkgarr) ; Select package
 ;@input
 ;  pkgarr  = variable by reference for array of package information
 ;@output
 ;  pkgarr("ien")      = ien into package file for packate
 ;  pkgarr("abb")      = abbreviation for this package
 ;  pkgarr("version")  = version of this package in use
 ;  pkgarr("name")     = name of package
 ;
 S DIC="^DIC(9.4,",DIC(0)="AEQMZ" D ^DIC
 quit:$data(DUOUT)  quit:(Y=-1)
 kill pkgarr
 set pkgarr("ien")=+$get(Y)
 set pkgarr("abb")=$piece($get(Y(0)),"^",2)
 set pkgarr("name")=$get(Y(0,0))
 set pkgarr("version")=$get(^DIC(9.4,pkgarr("ien"),"VERSION"))
 quit
 ;
 ;
 ;@ppi
LASTPTCH(pkgarr) ; Return last patch installed
 ;@input
 ;  pkgarr   = array of package information
 ;    pkgarr("ien")      = ien into package file for packate
 ;    pkgarr("abb")      = abbreviation for this package
 ;    pkgarr("version")  = version of this package in use
 ;    pkgarr("name")     = name of package
 ;@output
 ;  adds to pkgarr
 ;    pkgarr("patch#")   = patch # of last patch installed
 ;    pkgarr("seq#")     = sequence # of last patch installed
 ;    pkgarr("instdate") = install date/time last patch
 ;
 new PAHIEN,INSTLIEN,node,ss4
 set ss4=$order(^DIC(9.4,pkgarr("ien"),22,99999),-1)
 set PAHIEN=$order(^DIC(9.4,pkgarr("ien"),22,ss4,"PAH",99999),-1)
 if PAHIEN do
 . set pkgarr("patch#")=+$get(^DIC(9.4,pkgarr("ien"),22,ss4,"PAH",PAHIEN,0))
 . set pkgarr("ptchstrg")=pkgarr("abb")_"*"_pkgarr("version")_"*"_pkgarr("patch#")
 . set node=$na(^XPD(9.7,"B",pkgarr("ptchstrg")))
 . set node=$Q(@node)
 . quit:'($qs(node,3)=pkgarr("ptchstrg"))
 . set pkgarr("seq#")=+$piece($get(^XPD(9.7,$qs(node,4),6)),"^",2)
 . set pkgarr("instdate")=$piece($get(^XPD(9.7,$qs(node,4),1)),"^",3)
 quit
 ;
 ;
 ;@ppi
NXTPATCH(pkgarr) ; Find the next patch to install
 ;@input
 ;  pkgarr   = array of package information
 ;    pkgarr("ien")      = ien into package file for packate
 ;    pkgarr("abb")      = abbreviation for this package
 ;    pkgarr("version")  = version of this package in use
 ;    pkgarr("name")     = name of package
 ;    pkgarr("patch#")   = patch # of last patch installed
 ;    pkgarr("seq#")     = sequence # of last patch installed
 ;    pkgarr("instdate") = date/time last patch installed
 ;@output
 ;  adds pkgarr("nextpatch")
 ;
 ; If the array of all patches on our patch server
 ;   hasn't yet been built, do so now.
 if '$data(poo) do PATCHARR^KBAPKID1(.poo)
 ;
 ;
 ; When looking down patches for a package, remember
 ;   we need to account for the present version.  There
 ;   will be patches for previous versions we want to ignore.
 ;
 new node,snode,stop,seqstr,ptchstr,verstr,pkgver s stop=0
 s node=pkgarr("abb")
 s snode=node,node=$na(poo(node))
 s seqstr="SEQ-"_pkgarr("seq#")
 s ptchstr="PAT-"_pkgarr("patch#")
 s pkgver=pkgarr("version")
 s pkgver=$select(pkgver[".0":$piece(pkgver,"."),1:pkgver)
 ;
 ; Run down patches having the same package,patch and version
 ;  number.  Stop when we hit the last installed patch
 ;  Remember decimal versions may be nPn or npn for n.n
NP1 for  set node=$Q(@node) quit:'(node[snode)  do  quit:stop
 . set verstr=$piece($piece($QS(node,1),"_"),"-",2)
 .; be sure patch is same version
 . quit:'($tr(verstr,"pP","..")=pkgver)
 . if node[seqstr,node[ptchstr s stop=1
 ;
 ; Now drop to the next patch with the same package and
 ;  version number - if there is one.  This is the next
 ;  patch to install.
 set stop=0
NP2 for  set node=$Q(@node) quit:'(node[snode)  do  quit:stop
 . if node[seqstr,node[ptchstr quit
 . set verstr=$piece($piece($QS(node,1),"_"),"-",2)
 . if '($tr(verstr,"pP","..")=pkgver) set stop=2 quit
 . i node[pkgarr("abb"),node[verstr set stop=1 quit
 . set stop=2
 ;
 if (stop=1) set pkgarr("nextpatch")=node
 else  set pkgarr("nextpatch")="none"
 quit
 ;
 ;
 ;@ppi
PULLKIDS(pkgarr) ;
 ;@input
 ;  pkgarr  = package array passed by reference
 ;@output
 ;  gathers-files in ~/KIDS/ directory for install
 ;  returns k=KIDS file found, t=text file found
 ;          0 = no beginning checksum problems
 ;          1 = one or more before checksums failed
 ;          e.g "t" no KIDS found, "k" no text found
 ;              "0" for no begin checksum errors
 ;          e.g. "kt0" both text and KIDS found, no checksum
 ;               errors. Ready to load and install
 ;
 n nxtpstr,node,rslt,filename
 s rslt=""
 s node=$na(@(pkgarr("nextpatch")))
 s nxtpstr=$piece($qs(node,1),".")
 ; find all files with this patch string
 s node=$na(poo(nxtpstr))
 f  s node=$q(@node) quit:'(node[nxtpstr)  do
 . set filename=$QS(node,1)
 . do PULLPTCH^KBAPKID1(filename,"~/KIDS/")
 . if ($$UP^XLFSTR(filename)[".KID") do
 .. set rslt=$g(rslt)_"k"
 . if ($$UP^XLFSTR(filename)[".TXT") do
 .. set rslt=$g(rslt)_"t"
 .. set txtfile=filename
 ..;
 ..; Generate the .CKS file and return
 ..;   =0 no checksum errors, 1 = one or more routines failed chksum
 .. s rslt=$g(rslt)_$$KIDSCKS^KBAPKID1(filename,"/home/osehra/KIDS/",.pkgarr)
 ..;
 ;
 quit:$Q rslt  quit
 ;
EOR ; End of routine KBAPKIDS
