KBAPCKSM ;ven/lgc - Pull checksums from KIDS and docker ; 6/12/19 8:19pm
 ;;18.0;SAMI;;
 ;
 quit  ; no entry from top
 ;
 ;
TEST ; Test building array of KIDS checksums
 n path s path="/home/osehra/KIDS/"
 n filename s filename="PRCA-4p5_SEQ-286_PAT-327.txt"
 D KIDSCKS^KBAPCKSM(filename,path)
 quit
 ;
KIDSCKS(filename,path) ; Build array of KIDS routine checksums
 ;Input
 ;   filename  = name of the KIDS text file
 ;   path      = path to the KIDS file
 ;Exit
 ;   new file (*.CKS or *.CKSPI) with
 ;    routine name
 ;    before and after checksums
 ;    * notes checksum mismatch
 ;
 ; Run down file looking for
 ;    Routine Name: DDGF2
 ;        Before: B31932302   After: B31954979  **3,5**
 ; Build Array RTN(RTN NAME)=BEFORE AFTER STRING
 ; Run down RTN array
 ;   Print RTN NAME, BEFORE AND AFTER STRING, CHKSUM1 IN DOCKER
 ; Build new file with necessary info with "^" delimiters
 ;
 set:($get(path)="") path="/home/osehra/KIDS/"
 new ptchname,rtname,ptbefore,ptafter,rtchksm,outfile,RTN
 new instaldt,patchien,ptchstr,nextline
 set nextline=0
 set (ptchname,instaldt,patchien)=""
 set (rtname,ptbefore,ptafter,rtchksm,outfile)=""
 quit:($get(path)="")!($get(filename)="")
 do OPEN^%ZISH("FILE",path,filename,"R")
 if $get(POP) W !,!,"*** unable to open file ***",!,! quit
 ;
 new line
 for  use IO read line:1 quit:$$STATUS^%ZISH  do
 . U $P ; in case I want to debug
 .;
 .; if we have another line of patches after a
 .;    routine name, save it.
 . if $g(nextline) do  set nextline=0 quit
 .. quit:'(RTN(rtname)["*")
 .. set RTN(rtname)=RTN(rtname)_ptchstr_$translate(line," ")_"^"
 .;
 .; See if patch already installed
 . If line["Designation:" do  quit
 .. s ptchname=$tr($piece(line,"Designation:",2)," ")
 .. i '(+$p(ptchname,"*",2)=$p(ptchname,"*",2)) d
 ... s $p(ptchname,"*",2)=$p(ptchname,"*",2)_".0"
 .. s patchien=$O(^XPD(9.7,"B",ptchname,0))
 .. if $g(patchien) do
 ... write !,!,"Patch IEN in INSTALL file:",patchien,!,!
 ... s instaldt=$piece($get(^XPD(9.7,patchien,1)),"^",3)
 .;
 .; if line contains "Before" in correct position we have
 .;   a new routine
 . if $extract(line,5,11)="Before:" do  quit
KBAP1 .. set ptchstr=$piece(line,"**",2) ; string of patches
 .. set nextline=($length(line,"**")=2) ; second line of patches
 .. set ptbefore=$tr($p(line,":",2),"After B")
 .. set ptafter=$tr($p($p(line,":",3),"*")," B")
 .. set rtchksm=$$RTNCKSM(rtname)
 .. set RTN(rtname)=rtname_"^"
 .. set RTN(rtname)=RTN(rtname)_"PatchText"_"^"_ptbefore_"^"
 .. set RTN(rtname)=RTN(rtname)_ptafter_"^"
 .. if 'instaldt d
 ... set RTN(rtname)=RTN(rtname)_$$HTFM^XLFDT($H)_"^"
 ... set RTN(rtname)=RTN(rtname)_rtchksm_"^"
 ...; only display patch string of checksum not match "*"
 ... set RTN(rtname)=RTN(rtname)_$S('(ptbefore=rtchksm):"* "_ptchstr,1:"")_"^"
 ... if RTN(rtname)["*" U $P w !,RTN(rtname),!
 .. e  d
 ... set RTN(rtname)=RTN(rtname)_instaldt_"^"
 ... set RTN(rtname)=RTN(rtname)_rtchksm_"^"
 ...; only display patch string of checksum not match "*"
 ... set RTN(rtname)=RTN(rtname)_$S('(ptafter=rtchksm):"* "_ptchstr,1:"")_"^"
 .;
 .;
 . if $extract(line,1,13)="Routine Name:" do
 .. set rtname=$tr($p(line,":",2)," ")
 do CLOSE^%ZISH
S1 write !,!,"Patch Name : ",ptchname
 write !," Installed : ",instaldt,!,!
 ;
 n ptchext s ptchext=$S($get(instaldt)>0:".CKSPI",1:".CKS")
 s outfile=$piece(filename,".")_ptchext
 D BLDNEWF(path,outfile,.RTN)
 quit
 ;
 ;
RTNCKSM(RTNAME) ;
 quit:($get(RTNAME)="")
 new X,Y
 set X=RTNAME X ^%ZOSF("RSUM1")
 quit Y
 ;
 ;
BLDNEWF(path,outfile,RTN) ;
 new node,cnt
 set cnt=0
 set node=$na(RTN)
 do OPEN^%ZISH("FILE",path,outfile,"W")
 for  set node=$q(@node),cnt=cnt+1 q:((node="")!(cnt>100))  d
 . set line=@node
 . U IO write line,!
 do CLOSE^%ZISH
 w !,!,"file ",path,outfile," completed.",!
 quit
 ;
 ;
 ;
TEST2 ; Test pulling routine from KIDS
 new kidspath set kidspath="/home/osehra/KIDS/"
 new kidsname set kidsname="PRCA-4P5_SEQ-273_PAT-304.KIDS"
 new rtnname set rtnname="RCDPESP"
 new nrtnpath set nrtnpath="/home/osehra/run/routines/"
 do RFRMKIDS^KBAPCKSM(kidspath,kidsname,rtnname,nrtnpath)
 quit
 ;
RFRMKIDS(kidspath,kidsname,rtnname,nrtnpath) ; Pull routine from KIDS
 ;Input
 ;   kidspath   = path to find KIDS
 ;   kidsname   = name of KIDS
 ;   rtnname    = name of routine to pull from KIDS
 ;   nrtnpath   = path to where to save KBAPTMP.m
 ;Exit
 ;   KBAPTMP.m saved in rthpath
 ;
 kill ^KBAP("KBAPCKSM","RFRMKIDS") new linecnt s linecnt=0
 set:($get(kidspath)="") kidspath="/home/osehra/KIDS/"
 quit:($get(kidspath)="")!($get(kidsname)="")!($get(rtnname)="")
 n readme s readme=0
 do OPEN^%ZISH("FILE",kidspath,kidsname,"R")
 quit:POP
 new line,RTN
 for  use IO read line:1 quit:$$STATUS^%ZISH  do
 . if $p(line,",")["RTN",$tr($p(line,",",2),"""")=rtnname,$l(line,",")=4 do  quit
 .. set linecnt=$get(linecnt)+1,^KBAP("KBAPCKSM","RFRMKIDS",linecnt)=line
 .. U $P W !,line
 .. s readme=1
 . if readme d
 .. s readme=0
 .. U $P W !,line
 .. S RTN=$G(RTN)+1,RTN(RTN)=line
 do CLOSE^%ZISH
 ;
 ; Now save routine KBAPTMP.m
 n node set node=$na(RTN)
 if '$length($get(nrtnpath)) set nrtnpath="/home/osehra/run/routines/"
 ;restrict new routine to a maximum of 3,000 lines
 n cnt s cnt=0
 do OPEN^%ZISH("FILE",nrtnpath,"KBAPTMP.m","W")
 quit:POP
 for  set node=$q(@node),cnt=cnt+1 q:((node="")!(cnt>3000))  d
 . set line=@node
 . U IO write line,!
 do CLOSE^%ZISH
 do HOME^%ZIS
 write !,!,"file ",nrtnpath,"KBAPTMP.m completed.",!
 ;
 write !,"Routine Compare - KBAPTMP from KIDS vs "_rtnname,!
 ;
 set RTN1="KBAPTMP",RTN2=rtnname do CHECK^XTRCMP
 write !,!
 ;
 quit
 ;
 ;
EOR ; End of routine KBAPCKSM
