KBAPKID1 ;ven/lgc - Checksum KIDS utilities ; 7/18/19 2:54am
 ;;18.0;SAMI;;
 ;
 quit  ; no entry from top
 ;
 ;
 ;
 ;example
 ;D KIDSCKS("PRCA-4p5_SEQ-294_PAT-339.txt","/home/osehra/KIDS/")
 ; @api-code KIDSCKS^KBAPKID1
KIDSCKS(filename,path,pkgarr) ; Build array of KIDS routine checksums
 ;@called-by: 
 ;@calls
 ;  OPEN^%ZISH
 ;  CLOSE^%ZISH
 ;  BLDNEWF^KBAPKID1
 ;  $$STATUS^%ZISH
 ;  $$HTFM^XLFDT
 ;  RTNCKSM^KBAPKID1
 ;@input
 ;  filename  = name of the KIDS *text file
 ;  path      = path to the KIDS *text file
 ;  pkgarr    = pkgarr array by reference
 ;@output
 ;  file creation  (filename.CKS or filename.CKSPI) with
 ;    before or after checksums respecitively
 ;    * notes checksum mismatch
 ;  if called as extrinsic returns:
 ;    0 = no checksum errors
 ;    1 = one or more routines failed checksum
 ;   -1 = other error
 ;@tests
 ;  KBAPUTCK - not yet built
 ;@logic
 ;  Runs down KIDS assiciated text file and builds an
 ;   array RTN(routine name)with the Before checksum
 ;    the After checksum and the patch string for the
 ;    routine
 ;    e.g. RTN(rtnname)="Before: XXXXXXX After: YYYYYYY **3,5**"
 ;  Then run down RTN array, run a checksum on the routine
 ;   as it exists in environment now.  This is compared with
 ;   either the Before or After checksum pulled from the
 ;   the KIDS text file depending on whether the patch
 ;   has been installed.  
 ;  If the checksum doesn't match that expected an * and the
 ;   patch string for the routine are appended.  The string is
 ;   saved to the new file created.
 ;  The created file is saved under the same path where
 ;   the KIDS text file was found.
 ; 
 set:($get(path)="") path="/home/osehra/KIDS/"
 new ptchname,rtname,ptbefore,ptafter,rtchksm,outfile,RTN
 new instaldt,patchien,ptchstr,nextline,cksmatch
 set (cksmatch,nextline)=0
 set (ptchname,instaldt,patchien)=""
 set (rtname,ptbefore,ptafter,rtchksm,outfile)=""
 if ($get(path)="")!($get(filename)="") quit:$Q -1  quit
 do OPEN^%ZISH("FILE",path,filename,"R")
 if $get(POP) do  quit:$Q -1  quit
 . write !,!,"*** unable to open file ***",!,!
 ;
 new line
 for  use IO read line:1 quit:$$STATUS^%ZISH  do
 . use $P ; in case I want to debug
 .;
 .; save routine name
 . if $extract(line,1,13)="Routine Name:" do
 .. set rtname=$tr($tr($p(line,":",2)," "),$C(13))
 .;
 .; if we have another line of patches after a
 .;    routine name, save it.
 .;    NOTE: nextline set at KBAP1 when a line of patches
 .;          doesn't end with "**"
 .;
 . if $get(nextline) do  set nextline=0 quit
 .. quit:'(RTN(rtname)["*")
 .. set RTN(rtname)=RTN(rtname)_ptchstr_$translate(line," ")_"^"
 .;
 .; See if patch already installed.  If so collect
 .;   pull date patch installed
 .;
 . If line["Designation:" do  quit
 .. set ptchname=$tr($tr($piece(line,"Designation:",2)," "),$C(13))
 ..; if patch version is integer, add ".0"
 .. if $p(ptchname,"*",2)'["." do
 ... new ptchver s ptchver=$p(ptchname,"*",2)_".0"
 ... s $p(ptchname,"*",2)=ptchver
 .. ;
 .. ; save name of the next patch we will want to install
 .. set pkgarr("PatchToInstall")=$TR(ptchname,$C(13))
 .. if (+$p(ptchname,"*",2)=$p(ptchname,"*",2)) do
 ... set $piece(ptchname,"*",2)=$piece(ptchname,"*",2)_".0"
 .. set patchien=$O(^XPD(9.7,"B",ptchname,0))
 .. if $g(patchien) do
 ... write !,!,"Patch IEN in INSTALL file:",patchien,!,!
 ... set instaldt=$piece($get(^XPD(9.7,patchien,1)),"^",3)
 .;
 .; if line contains "Before" in correct position we have
 .;   a new routine
 .;
 . if $extract(line,5,11)="Before:" do  quit
KBAP1 .. set ptchstr=$piece(line,"**",2) ; string of patches
 ..;
 ..; if there isn't an ending "**" then there are more
 ..;  patches listed on the next line we read
 .. set nextline=($length(line,"**")=2) ; second line of patches
 ..;
 .. set ptbefore=$tr($p(line,":",2),"After B")
 .. set ptafter=$tr($p($p(line,":",3),"*")," B")
 .. set rtchksm=$$RTNCKSM(rtname)
 .. set RTN(rtname)=rtname_"^"
 .. set RTN(rtname)=RTN(rtname)_"PatchText"_"^"_ptbefore_"^"
 .. set RTN(rtname)=RTN(rtname)_ptafter_"^"
 ..;
 ..; If the patch has not been installed
 ..;   compare the BEFORE checksum with active routine
 ..;
 .. if 'instaldt do
 ... set RTN(rtname)=RTN(rtname)_$$HTFM^XLFDT($H)_"^"
 ... set RTN(rtname)=RTN(rtname)_rtchksm_"^"
 ...;
 ...; only display patch string of checksum not match "*"
 ...;
 ... if ('(ptbefore=rtchksm)),('$$UP^XLFSTR(RTN(rtname))["N/A") do
 .... set RTN(rtname)=RTN(rtname)_"* "_ptchstr
 .... use $P write !,RTN(rtname),!
 .... set cksmatch=1
 ... set RTN(rtname)=RTN(rtname)_"^"
 ..;
 ..; If the patch has been installed compare the AFTER
 ..;   checksum with the active routine
 ..;
 .. else  do
 ... set RTN(rtname)=RTN(rtname)_instaldt_"^"
 ... set RTN(rtname)=RTN(rtname)_rtchksm_"^"
 ... if '(ptafter=rtchksm) do
 .... set RTN(rtname)=RTN(rtname)_"* "_ptchstr
 .... use $P write !,RTN(rtname),!
 .... set cksmatch=1
 .;
 .;
 do CLOSE^%ZISH
 ;
S1 write !,!,"Patch Name : ",ptchname
 write !," Installed : ",instaldt,!,!
 ;
 new ptchext s ptchext=$Select($get(instaldt)>0:".CKSPI",1:".CKS")
 set outfile=$piece(filename,".")_ptchext
 do BLDNEWF(path,outfile,.RTN)
 quit:$Q cksmatch  quit
 ;
 ;
 ;@ppi
RTNCKSM(RTNAME) ; Return checksum of routine
 ;@input
 ;  RTNAME  = name of routine
 ;@output
 ;  Returns checksum of routine (CHECK1^XTSUMBLD)
 quit:($get(RTNAME)="")
 new X,Y
 set X=RTNAME X ^%ZOSF("RSUM1")
 quit Y
 ;
 ;
 ;@ppi
BLDNEWF(path,outfile,RTN) ; Build a new file with KIDS routine checksums
 ;@input
 ;  path      = path (directory) where file is to be written
 ;  outfile   = name and extension of file to write
 ;  RTN       = array by reference of lines to write to file
 ;            e.g. RTN("OOPSGUI1")="OOPSGUI1^PatchText^34497332^34497330^3190715.162213^34497330^"
 ;output
 ;  creates-file of routines and before and after checksums
 ;zwr RTN ; debug
 new node,cnt
 set cnt=0
 set node=$na(RTN)
 do OPEN^%ZISH("FILE",path,outfile,"W")
 for  set node=$q(@node),cnt=cnt+1 q:((node="")!(cnt>100))  d
 . set line=@node
 . use IO write line,!
 do CLOSE^%ZISH
 write !,!,"file ",path,outfile," completed.",!
 quit
 ;
 ;
 ;
 ;
 ;@example
 ;  do RFRMKIDS(kidspath,kidsname,rtnname,nrtnpath)
 ;  do RFRMKIDS("/home/osehra/KIDS/","OOPS-2_SEQ-21_PAT-22.KID","OOPSGUI7","/home/osehra/run/routines/")
 ;@ppi - Pull a routine from KIDS file
RFRMKIDS(kidspath,kidsname,rtnname,nrtnpath) ; Pull routine from KIDS
 ;@input
 ;   kidspath   = path to find KIDS
 ;   kidsname   = name of KIDS
 ;   rtnname    = name of routine to pull from KIDS
 ;   nrtnpath   = path to where to save the requested routine
 ;                 renamed KBAPTMP.m so as not to overlay the existing
 ;                 routine in VistA
 ;@output
 ;   KBAPTMP.m (routine pulled from KIDS) saved in nrtnpath
 ;   KBAPTMP.m and rtnname.m run through ^XTRCMP so any differences
 ;     will be displayed to user
 new line,linecnt,readme,RTN
 set linecnt=0
 set:($get(kidspath)="") kidspath="/home/osehra/KIDS/"
 quit:($get(kidspath)="")!($get(kidsname)="")!($get(rtnname)="")
 set readme=0
 do OPEN^%ZISH("FILE",kidspath,kidsname,"R")
 quit:POP
 ;
 ; The each line of a routine in a KIDS file is prefaced with the
 ;   "RTN" , the name of the routine , the line number
 for  use IO read line:1 quit:$$STATUS^%ZISH  do
 .;
 . if $p(line,",")["RTN",$tr($p(line,",",2),"""")=rtnname,$l(line,",")=4 do  quit
 .. set linecnt=$get(linecnt)+1
 .. use $P write !,line
 .. set readme=1
 .;
 . if readme do
 .. set readme=0
 .. use $P write !,line
 .. set RTN=$get(RTN)+1,RTN(RTN)=line
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
 . use IO write line,!
 do CLOSE^%ZISH
 do HOME^%ZIS
 write !,!,"file ",nrtnpath,"KBAPTMP.m completed.",!
 ;
 ; Run the routine compare of the routine pulled from
 ;  the KIDS against that presently on the client
 write !,"Routine Compare - KBAPTMP from KIDS vs "_rtnname,!
 ;
 set RTN1="KBAPTMP",RTN2=rtnname do CHECK^XTRCMP
 write !,!
 ;
 quit
 ;
 ;
 ;
 ;e.g. D PULLPTCH^KBAPKID1("XU-8_SEQ-446_PAT-561.TXT","~/KIDS/")
 ;e.g. D PULLPTCH^KBAPKID1("AllPatches.txt","~/KIDS/")
 ;@api - Pull a patch from patch server
PULLPTCH(ptchname,path) ; Pull a patch from patch server
 ;@input
 ;  ptchname  = name of file to pull from patch server
 ;  path      = path on this client to save file
 ;@output
 ;  create-file on client
 ;
 write !,!,"ptchname=",ptchname,!,"path=",path,!
 new url,cmd,filename
 ; set url to patch server address and patch file to pull
 set url="http://patch.fiscientific.org:9080/filesys/sami/patch/"
 set url=url_ptchname
 ; set filename to the path and name of file to save on client
 set filename=path_ptchname
 ;
 set cmd="curl -o "_filename_" "_url
 zsystem cmd
 quit
 ;
 ;
 ;@ppi - Build an array of all patches from patch server
PATCHARR(ptcharr) ; Build array of all patches from patch server
 ;@input
 ;  ptcharr variable by reference for the array
 ;@output
 ;  ptcharr array of all patch entries on patch server
 ;  e.g. poo("TIU-1_SEQ-239_PAT-239.TXT")="" 
 ;
 ; NOTE:
 ; AllPatches.txt was created on the patch server when
 ;  the patches were pulled from the OSEHRA web site
 ;  by sending the directory list to this file
 ; Refresh this file from the patch server
 D PULLPTCH^KBAPKID1("AllPatches.txt","~/KIDS/")
 ;
 ; Now use AllPatches.txt to build our local array
 do OPEN^%ZISH("FILE","/home/osehra/KIDS/","AllPatches.txt","R")
 quit:POP
 new line
 kill ptcharr
 for  use IO read line:1 quit:$$STATUS^%ZISH  do
 . quit:$E(line,1,8)="Patches-"
 . set ptcharr($tr(line,""""))=""
 do CLOSE^%ZISH
 ; Fix special patch problem with PRCA*4.5*317
 kill ptcharr("PRCA-4P5_SEQ-278_PAT-317.TXT")
 set ptcharr("PRCA-4p5_SEQ-278_PAT-317.TXT")=""
 quit
 ;
 ;@ppi
POSTICHK(path,filename) ;
 ;Input
 ;  filename = name including extension of .CKS file to open
 ;Output
 ;  creates-file  filename.CKSPI with post install checksums
 ;
 ; Use the BEFORE install .CKS file to build our local array
 ;
 ;e.g. PatchText^befor chksum^after chksum^date^active rtn chksum
 ; "^PatchText^13617982^14988614^3190712.203343^13617982^^"
 ; "^PatchText^n/a^1842298^3190712.203343^0^^"
 new cksmatch set cksmatch=-1
 q:filename="" cksmatch
 if $get(path)="" set path="/home/osehra/KIDS/"
 do OPEN^%ZISH("FILE",path,filename,"R")
 quit:POP cksmatch
 new line,RTN,cnt
 kill RTN
 set cnt=0
 for  use IO read line:1 quit:$$STATUS^%ZISH  do
 . set cnt=$g(cnt)+1
 . set RTN(cnt)=line
 do CLOSE^%ZISH
 zwr RTN
 ;
 ; Check that the checksum of the active routine
 ;   is the same as that expected after install
 ;
 ; RTN(1)="DDGF2^PatchText^31932302^31954979^3190718.02313^31954979^^"
 new rtname,postchks,actchks
 s rtname=$p(RTN(cnt),"^")
 s postchks=$p(RTN(cnt),"^",4)
 s actchks=$$xxx(rtname)
 s $p(RTN(cnt),"^",5)=fmdate
 s $p(RTN(cnt),"^",6)=actchks
 if '(actchks=postchks) s $p(RTN(cnt),"^",7)="*"
 else s $p(RTN(cnt),"^",7)=""
 ; set some variable to 0 or 1 depending on if any "*"
 write out file with CKSPI extension
 return the success variable
 quit success
 ;
 quit
 ;
 ;
EOR ; End of routine KBAPKID1
