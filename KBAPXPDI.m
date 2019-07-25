KBAPXPDI ;;ven/lgc - Load Distribution Global; 7/3/19 9:15am ; 7/25/19 4:34pm
 ;;18.0;SAMI;;
 ;
 ;XPDI - SFISC/RSD - Install Process ; 7/3/19 9:18pm
 ;;8.0;KERNEL;**10,21,39,41,44,58,68,108,145,184,229**;Jul 10, 1995
 ;
 ;
START(pkgarr) ;
 ;
 ;ZB EN1^KBAPXPDI
 ;ZB EN2^KBAPXPDI
 ;ZB EN3^KBAPXPDI
 ;ZB EN4^KBAPXPDI
 ;ZB EN5^KBAPXPDI
 ;ZB EN6^KBAPXPDI
 ;ZB EN7^KBAPXPDI
 ;ZB EN8^KBAPXPDI
 ;ZB ENCPUS^KBAPXPDI
 ;ZB DEV^KBAPXPDI
 ;ZB ENQUE^KBAPXPDI
 ;ZB ENRUN^KBAPXPDI
 ;ZB DIR^KBAPXPDI
 ;ZB QUES^KBAPXPDI
 ;ZB DIR1^KBAPXPDI
 ;ZB DIRUPDT^KBAPXPDI
 ;ZB DIURPDT1^KBAPXPDI
 ;ZB SETXPDQ^KBAPXPDI
 ;ZB QUES1^KBAPXPDI
 ;ZB XQSET^KBAPXPDI
 ;S $ZSTEP="W $T(@$ZPOS),! BREAK"
 ;
 new DIR,DIRUT,POP,XPD,XPDA,XPDD,XPDIJ,XPDDIQ,XPDIT,XPDIABT,XPDNM
 new XPDNOQUE,XPDPKG,XPDREQAB,XPDST,XPDSET,XPDSET1,XPDT,XPDQUIT
 new XPDQUES,Y,ZTSK,%,X,Y
 ;
 set X=pkgarr("PatchToInstall")
 set XPDST=$order(^XPD(9.7,"B",pkgarr("PatchToInstall"),0))
 set XPD1(1)=XPDST_"^"_X
 set XPD("DA",XPDST)=1
 set XPD("NM",pkgarr("PatchToInstall"))=1
 merge XPDT=XPD
 merge XPDT=XPD1
 ;
 ;
EN ;install
 ;N DIR,DIRUT,POP,XPD,XPDA,XPDD,XPDIJ,XPDDIQ,XPDIT,XPDIABT,XPDNM,XPDNO;QUE,XPDPKG,XPDREQAB,XPDST,XPDSET,XPDSET1,XPDT,XPDQUIT,XPDQUES,Y,ZTSK,%
 ;S %="I '$P(^(0),U,9),$D(^XPD(9.7,""ASP"",Y,1,Y)),$D(^XTMP(""XPDI"",Y))",XPDST=$$LOOK^XPDI1(%)
 ;Q:'XPDST!$D(XPDQUIT)
 ;
EN1 S XPDIT=0,(XPDSET,XPDSET1)=$P(^XPD(9.7,XPDST,0),U) K ^TMP($J)
 ;Check each part of XPDT array
 F  S XPDIT=$O(XPDT(XPDIT)) Q:'XPDIT  D  Q:'$D(XPDT)!$D(XPDQUIT)
 .S XPDA=+XPDT(XPDIT),XPDNM=$P(XPDT(XPDIT),U,2),XPDPKG=+$P($G(^XPD(9.7,+XPDT(XPDIT),0)),U,2),%=$P(^(0),U,5)
 .W !,"Checking Install for Package ",XPDNM
 .;check that Install file was created correctly
 .I '$D(^XPD(9.7,XPDA,"INI"))!'$D(^("INIT")) W !,"**INSTALL FILE IS CORRUPTED**",!,*7 S XPDQUIT=1 Q
 .;
 .;run enviroment check routine
 .;XPDREQAB req. build missing, =2 global killed
EN2 .I $$ENV^XPDIL1(1) S:$G(XPDREQAB)=2 XPDQUIT=1 Q
 .;save variables that are setup in environ. chck. routine
 .I $D(XPDNOQUE)!$D(XPDDIQ) D
 ..S:$D(XPDNOQUE) ^XTMP("XPDI",XPDA,"ENVVAR","XPDNOQUE")=XPDNOQUE
 ..I $D(XPDDIQ) M ^XTMP("XPDI",XPDA,"ENVVAR","XPDDIQ")=XPDDIQ
 .;
 .; this is where Rebuild Menu Trees asked
 .;  so QUES and XQSET of XPDI1 copied into this routine
EN3 .D QUES1^KBAPXPDI(XPDA) Q:'$D(XPDT(+XPDIT))!$D(XPDQUIT)
 .;
 .;XPDIJ=XPDA if XPDIJ routine is part of Build
 .S:$D(^XTMP("XPDI",XPDA,"RTN","XPDIJ")) XPDIJ=XPDA
 .;
 .D XQSET^KBAPXPDI(XPDA)
 ;
 ;NONE = no Build to install
 G NONE:'$O(XPDT(""))!$D(XPDQUIT)!($G(XPDREQAB))
 ;
 ;check that we have all Builds to install
EN4 S XPDA=XPDST,XPDNM=XPDSET,Y=0
 F  S Y=$O(^XPD(9.7,"ASP",XPDA,Y)) Q:'Y  S %=+$O(^(Y,0)) I '$D(XPDT("DA",%)) G NONE
 W !
 ;
 ;See if a Master Build
EN5 S %=$O(^XTMP("XPDI",XPDA,"BLD",0)),%=$P(^(%,0),U,3) S:%=1 XPDT("MASTER")=XPDA
 ;
 ;Inhibit Logon Question
EN6 D DIR^KBAPXPDI("XPI") I $D(DIRUT) D ABRTALL(2) Q
 ;
 ;disable options question
EN7 D DIR^KBAPXPDI("XPZ") I $D(DIRUT) D ABRTALL(2) Q
 ;
 ;XPDSET=set name,(also build name), of options that will be disabled
 ;XPDSET1=setname or null if they don't want to disable
EN8 D  I XPDSET1="^" D ABRTALL(2) Q
 .;if they say no, set XPDET1=""
 .S:'$G(XPDQUES("XPZ1")) XPDSET1="",Y=0
 .S ^XTMP("XQOO",XPDSET,0)=XPDSET_" is being installed by KIDS^"_DT_U_DUZ
 .I XPDSET1]"" D  Q:XPDSET1="^"!(XPDSET1="")
 ..;
 ..;merge the options/protocols that were put in ^TMP($J,"XQOO",build name)
 ..M ^XTMP("XQOO",XPDSET)=^TMP($J,"XQOO",XPDSET)
 ..D INIT^XQOO(.XPDSET1) Q:"^"[XPDSET1
 ..N DIR S DIR(0)="N^0:60:0",DIR("B")=0
 ..S DIR("A")="Delay Install (Minutes)",DIR("?")="Enter the number of minutes to delay the installing of Routines after the Disable of Options"
 ..W ! D ^DIR I $D(DIRUT) S XPDSET1="^"
 .;
 .;Y is set in the call to DIR in previous .DO
 .;save setname into first Build and the Delay in minutes, Y
 .K XPD S XPD(9.7,XPDST_",",7)=(XPDSET1]"")_XPDSET,XPD(9.7,XPDST_",",8)=Y
 .D FILE^DIE("","XPD")
 ;
 ;check if they want to update other CPUs
ENCPUS I $G(XPDQUES("XPZ2")) D  I $D(DIRUT) D ABRTALL(2) Q
 .N DA,DIE,DIR,DR,I,XPD,X,Y,Z
 .;if they haven't already added Volume Sets, populate the mulitple
 .I '$O(^XPD(9.7,XPDA,"VOL",0)) D  I $D(XPD) D UPDATE^DIE("","XPD")
 ..X ^%ZOSF("UCI") S Y=$P(Y,",",2),(I,Z)=0
 ..F  S I=$O(^%ZIS(14.5,I)) Q:'I  S X=$G(^(I,0)) S:$P(X,U)]""&$P(X,U,11)&($P(X,U)'=Y) Z=Z+1,XPD(9.703,"+"_Z_","_XPDA_",",.01)=$P(X,U)
 .W !!,"I will Update the following VOLUME SETS:",!
 .S I=0 F  S I=$O(^XPD(9.7,XPDA,"VOL",I)) Q:'I  W ?3,$P(^(I,0),U),!
 .W ! S DIR(0)="Y",DIR("A")="Want to edit this list",DIR("B")="NO"
 .D ^DIR Q:$D(DIRUT)  D:Y
 ..S DA=XPDA,DIE="^XPD(9.7,",DR=30,DR(2,9.703)=".01"
 ..D ^DIE
 .I '$O(^XPD(9.7,XPDA,"VOL",0)) W !!,"No VOLUME SETS selected!!" Q
 .Q:$$TM^%ZTLOAD  ;quit if Taskman is running
 .W !!,"TASKMAN is not running. If you install now, you must run the routine XPDCPU",!,"in the production UCI for each of the VOLUME SETS you have listed once"
 .W !,"the installation starts!!",!,"If you Queue the install, the VOLUME SETS will be updated automatically.",*7,*7,!!
 ;
DEV S POP=0 S:'$D(^DD(3.5,0)) POP=1
 ;check if home device is defined
 I 'POP S IOP="",%ZIS=0 D ^%ZIS
 ;
 ;Kernel Virgin Install
 I POP S XPDA=XPDST D:$G(XPDIJ) XPDIJ^XPDI1 G EN^XPDIJ
 ;set XPDA=starting Build, ask for device for messages
 ;XPDNOQUE is defined means don't let them queue output
 ;
 ; No user interaction
 ;W !!,"Enter the Device you want to print the Install messages."
 ;W:'$D(XPDNOQUE) !,"You can queue the install by enter a 'Q' at the device prompt."
 ;W !,"Enter a '^' to abort the install.",!
 ;S XPDA=XPDST,%ZIS=$P("Q",U,'$D(XPDNOQUE))
 ;D ^%ZIS G:POP ASKABRT
 ;
 ;reset expiration date to T+7 on transport global
 S XPDD=$$FMADD^XLFDT(DT,7),^XTMP("XPDI",0)=XPDD_U_DT
 ;
ENQUE I $D(IO("Q")) D  G ASKABRT:$D(ZTSK)[0 D XPDIJ^XPDI1:$G(XPDIJ),QUIT^XPDI1(XPDST) Q
 . N DIR,NOW S NOW=$$HTFM^XLFDT($$HADD^XLFDT($H,,,2)) ;Must be in future
 . S DIR(0)="DA^"_NOW_":"_XPDD_":AEFRSX"
 . S DIR("A")="Request Start Time: "
 . S DIR("B")=$$FMTE^XLFDT(NOW)
 . S DIR("?",1)="Enter a Date including Time"
 . S DIR("?",2)="The time must be in the future and not to exceed 7 days in the future."
 . S DIR("?")="Current date/time: "_DIR("B")
 . D ^DIR
 .Q:$D(DIRUT)
 .S ZTDTH=Y,ZTRTN="EN^XPDIJ",ZTDESC=XPDNM_" KIDS install",ZTSAVE("XPDA")=""
 .D ^%ZTLOAD,HOME^%ZIS K IO("Q")
 .Q:$D(ZTSK)[0
 .W !,"Install Queued!",!!
 .;save task into first Build
 .K XPD S XPD(9.7,XPDST_",",5)=ZTSK,XPDIT=0
 .F  S XPDIT=$O(XPDT(XPDIT)) Q:'XPDIT  S XPD(9.7,+XPDT(XPDIT)_",",.02)=1 D FILE^DIE("","XPD") K XPD
 ;
ENRUN ;run install
 U IO D XPDIJ^XPDI1:$G(XPDIJ),QUIT^XPDI1(XPDST) G EN^XPDIJ
 Q
 ;
 ;XPDA=ien to del, XPDK=1 kill global, XPDALL=1 deleting all
 ;XPDST=starting package.
ABORT(XPDA,XPDK,XPDALL) ;abort install of Build XPDA
 N %,DA,DIK,XPDJ,XPDNM,Y
 Q:'$D(^XPD(9.7,XPDA,0))  S XPDNM=$P(^(0),U)
 D BMES^XPDUTL(XPDNM_" Build will not be installed"_$S(XPDK=1:", Transport Global deleted!",1:"")),MES^XPDUTL("               "_$$HTE^XLFDT($H))
 S DIK="^XPD(9.7,",XPDJ=XPDT("NM",XPDNM),DA=XPDA
 ;kill XPDT array, but don't kill global if XPDK=2
 K XPDT("NM",XPDNM),XPDT("DA",XPDA),XPDT(XPDJ),XPDT("GP") Q:XPDK=2
 K ^XTMP("XPDI",XPDA)
 ;if we are not deleting all packages and we are deleting the starting package
 ;set the next package to the starting package. It must always be 1.
 I '$G(XPDALL),XPDA=XPDST S Y=$O(XPDT(0)) D:Y
 .;unlock starting install
 .L -^XPD(9.7,XPDST)
 .S XPDST=+XPDT(Y),XPDT(1)=XPDT(Y),XPDT("DA",XPDST)=1,XPDT("NM",$P(XPDT(Y),U,2))=1,XPDIT=0
 .K XPDT(Y) N XPD
 .S %="XPD(9.7,"""_XPDST_","")",@%@(3)=XPDST,@%@(4)=1
 .;loop thru the rest of the packages and reset the starting package field
 .F  S Y=$O(XPDT(Y)) Q:'Y  D
 ..S XPD(9.7,+XPDT(Y)_",",3)=XPDST
 .D FILE^DIE("","XPD")
 D ^DIK
 Q
 ;
ASKABRT ;ask if want to unload distribution
 N DIR,DIRUT,X,Y
 S XPDQUIT=1,DIR(0)="Y",DIR("A")="Install ABORTED, Want to remove the Transport Globals",DIR("B")="YES"
 W ! D ^DIR I Y D ABRTALL(1) Q
 L -^XPD(9.7,XPDST)
 Q
 ;
ABRTALL(XPDK) ;abort all Builds
 N XPDA
 S XPDT=0
 F  S XPDT=$O(XPDT(XPDT)) Q:'XPDT  S XPDA=+XPDT(XPDT) D ABORT(XPDA,XPDK,1)
 ;unlock starting install
 L -^XPD(9.7,XPDST)
 Q
 ;
NONE W !!,"**NOTHING INSTALLED**",!
 Q
 ;
 ;
ENXPDIQ ;XPDIQ --- SFISC/RSD - Install Questions ;03/21/2008
 ;;8.0;KERNEL;**21,28,58,61,95,108,399**;Jul 10, 1995;Build 12
 Q
 ;
 ; ============== PULLED FROM XPDIQ ========================
DIR(XPFR,XPFP) ;XPFR=prefix, XPFP=file no._# or Mail Group ien
 ;XPFP is for XPF  or XPM questions
 N DIR,DR,XPDI,XPDJ,X,Y,Z
 S XPFP=$G(XPFP),XPDI=$S(XPFP:XPFR_XPFP,1:XPFR)
 ;
 ; build XPDQUES array
 D QUES^KBAPXPDI(XPDI)
 ;
 ;ask questions
 S X=XPFR
 F  S X=$O(^XTMP("XPDI",XPDA,"QUES",X)),Z="" Q:X=""!($P(X,XPFR)]"")  D  I $D(DIRUT) S XPDQUIT=1 Q
 .S XPDJ=$S('XPFP:X,1:XPDI_$P(X,XPFR,2))
 .F  S Z=$O(^XTMP("XPDI",XPDA,"QUES",X,Z)) Q:Z=""  M DIR(Z)=^(Z)
 .;if there was a previous answer, reset DIR("B") to external or internal answer
 .S:$L($G(XPDQUES(XPDJ))) DIR("B")=$G(XPDQUES(XPDJ,"B"),XPDQUES(XPDJ)) D  Q:'$D(Y)
 ..N FLAG,X,Z K Y
 ..;this is the M CODE node that was set to DIR("M") in prev for loop
 ..;FLAG is used by KIDS questions
 ..I $D(DIR("M")) S %=DIR("M"),FLAG="" K DIR("M") X %
 ..Q:'$D(DIR)
 ..;'|' is used to mark variable in prompt, reset prompt with value of variable
 ..S:$G(DIR("A"))["|" DIR("A")=$P(DIR("A"),"|")_@$P(DIR("A"),"|",2)_$P(DIR("A"),"|",3)
 ..K:$G(DIR("B"))="" DIR("B")
 ..;
 ..; variables at this point
 ..; %="D XPI1^XPDIQ"
 ..; DIR(0)="YO"
 ..; DIR("??")="^D INHIBIT^XPDH"
 ..; DIR("A")="Want KIDS to INHIBIT LOGONs during the install"
 ..; DIR("B")="NO"
 ..; XPDQUES("XPI1")=0
 ..; XPDQUES("XPI1","A")="Want KIDS to INHIBIT LOGONs during the install"
 ..; XPDQUES("XPI1","B")="NO"
 ..; no X or Y defined
 ..;
DIR1 ..;D ^DIR
 ..; We don't want human intervention so we will do
 ..;  this update rather than allow ^DIR to do so
 ..D
 ... N X,Y S Y=1 
 ... S XPDI=XPDJ Q:XPDI=""!($P(XPDI,XPFR)]"")
 ... S X="XPDJ(9.701,""?+"_Y_","_XPDA_","")"
 ... S @X@(.01)=$G(XPDJ)
 ... S @X@(1)=$G(DIR("A"))
 ... S @X@(2)=$G(DIR("B"))
 ... S @X@(3)=$S(DIR("B")["N":0,1:1)
 ... K XPDI D:$D(XPDJ)>9 UPDATE^DIE("","XPDJ","XPDI")
 ...;
 ..;
 .;S %=$P(DIR(0),U)
 .;read was optional and didn't timeout and user didn't enter anything
 .;
 .; variables
 .; %="YO"
 .;I %["O",'$D(DTOUT),$S(%["P":Y=-1,1:Y="") K DIRUT Q
 .;quit if the user up-arrowed out
 .;Q:$D(DIRUT)
 .;if pointer, reset Y & Y(0)
 .;I %["P" S Y(0)=$S(%["Z":$P(Y(0),U),1:$P(Y,U,2)),Y=+Y
 .;if Y(0) is not defined, but Y is
 .;S:$D(Y)#2&'($D(Y(0))#2) Y(0)=Y
 .;
 .; Y=0
 .; set XPDQUES
SETXPDQ .;
 . S XPDQUES(XPDJ,1)=Y
 . S XPDQUES(XPDJ,"A")=$G(DIR("A"))
 . S XPDQUES(XPDJ,"B")=$G(Y(0))
 .;
 .;variables
 .; XPDQUES("XPI1")=0
 .; XPDQUES("XPI1","A")="Want KIDS to INHIBIT LOGONs during the install"
 .; XPDQUES("XPI1","B")="NO"
 . K DIR
 ;
 K XPDJ S XPDI=XPFR
 ;
 ; variables
 ;  XPDI="XPI"
 ;
 ;code to save XPDQUES to INSTALL ANSWERS in file 9.7, loop thru the answers starting with the from value, XPFR
 ; e.g.
 ; XPDQUES("XPI1")=0
 ; XPDQUES("XPI1","A")="Want KIDS to INHIBIT LOGONs during the install"
 ; XPDQUES("XPI1","B")="NO"
 ;
 ;F Y=1:1 S XPDI=$O(XPDQUES(XPDI)) Q:XPDI=""!($P(XPDI,XPFR)]"")  D
 ;.S X="XPDJ(9.701,""?+"_Y_","_XPDA_","")"
 ;.S @X@(.01)=XPDI
 ;.S @X@(1)=$G(XPDQUES(XPDI,"A"))
 ;.S @X@(2)=$G(XPDQUES(XPDI,"B"))
 ;.S @X@(3)=XPDQUES(XPDI)
 ;
DIRUPDT ;
 ;X="XPDJ(9.701,""?+1,10198,"")"
 ;Y=2
 ;Y(0)="NO"
 ;XPDIT="DA"
 ;XPDJ(9.701,"?+1,10198,",.01)="XPI1"
 ;XPDJ(9.701,"?+1,10198,",1)="Want KIDS to INHIBIT LOGONs during the install"
 ;XPDJ(9.701,"?+1,10198,",2)="NO"
 ;XPDJ(9.701,"?+1,10198,",3)=0
 ;
DIURPDT1 ;K XPDI D:$D(XPDJ)>9 UPDATE^DIE("","XPDJ","XPDI")
 Q
 ;
QUES(X) ;build XPDQUES array, X="INI","INIT","XPF","XPM"
 ;move INSTALL ANSWERS from file 9.7 to XPDQUES
 ;XPDQUES(X)=internal answer, XPDQUES(X,"A")=prompt, XPDQUES(X,"B")=external answer.
 N Y,Z K XPDQUES S Z=X
 ;
 ; e.g. expects data in 9.7 QUES nodes
 ;  ^XPD(9.7,10198,"QUES",0)="^9.701^2^2"
 ;  ^XPD(9.7,10198,"QUES",1,0)="XPI1"
 ;  ^XPD(9.7,10198,"QUES",1,1)=0
 ;  ^XPD(9.7,10198,"QUES",1,"A")="Want KIDS to INHIBIT LOGONs during the install"
 ;  ^XPD(9.7,10198,"QUES",1,"B")="NO"
 ;  ^XPD(9.7,10198,"QUES",2,0)="XPZ1
 ;  ^XPD(9.7,10198,"QUES",2,1)=0
 ;  ^XPD(9.7,10198,"QUES",2,"A")="Want to DISABLE Scheduled Options, Menu Options, and Protocols
 ;  ^XPD(9.7,10198,"QUES",2,"B")="NO"
 ;  ^XPD(9.7,10198,"QUES","B","XPI1",1)=""
 ;  ^XPD(9.7,10198,"QUES",2,"B")="NO"
 ;  ^XPD(9.7,10198,"QUES","B","XPI1",1)=""
 ;  ^XPD(9.7,10198,"QUES","B","XPI1",1)=""
 ;  ^XPD(9.7,10198,"QUES","B","XPZ1",2)=""
 ;
 F  S Z=$O(^XPD(9.7,XPDA,"QUES","B",Z)) Q:Z=""!($P(Z,X)]"")  S Y=$O(^(Z,0)) D
 . Q:'$D(^XPD(9.7,XPDA,"QUES",Y,0))
 . S XPDQUES(Z)=$G(^(1)) ; ^XPD(9.7,XPDA,"QUES","B",1
 . S XPDQUES(Z,"A")=$G(^("A"))
 . S XPDQUES(Z,"B")=$G(^("B")) ; ^(1) refer to prev line ^XPD(9.7,XPDA,"QUES","B",Z)
 Q
 ;
 ; ========================= END OF XPDIQ ============================
 ;
 ; ========================= START OF XPDI1 =======================
 ;XPDI1 --- SFISC/RSD - Cont of Install Process ;10/28/2002  17:14
 ;;8.0;KERNEL;**58,61,95,108,229,275**;Jul 10, 1995
 ;
QUES1(XPDA) ;install questions; XPDA=ien in file 9.7
 N XPDANS,XPDFIL,XPDFILN,XPDFILO,XPDFLG,XPDNM,XPDQUES,X,Y
 S XPDNM=$P(^XPD(9.7,XPDA,0),U) W !!,"Install Questions for ",XPDNM,!
 ;pre-init questions
 D DIR^KBAPXPDI("PRE") I $D(XPDQUIT) D ASKABRT^XPDI Q
 ;
 ;file install questions
 S (XPDFIL,XPDFLG)=0
 F  S XPDFIL=$O(^XTMP("XPDI",XPDA,"FIA",XPDFIL)) Q:'XPDFIL  S X=^(XPDFIL),X(0)=^(XPDFIL,0),X(1)=^(XPDFIL),XPDFILO=^(0,1) D  Q:$D(XPDQUIT)
 .;check for DD screening logic
 .I $G(^(10))]"" N XPDSCR S XPDSCR=^(10) ;^(10) is ref to ^XTMP("XPDI",XPDA,"FIA",XPDFIL,0,10) from prev line
 .;XPDFILN=file name^global ref^partial DD
 .;XPDANS=new file^DD screen failed^Data exists^update file name^user
 .;doesn't want to update data  1=yes,0=no
 .S XPDFILN=X_X(0)_U_X(1),XPDANS='($D(^DIC(XPDFIL,0))#2)_"^^"_''$O(@(X(0)_"0)"))
 .I 'XPDFLG W !,"Incoming Files:" S XPDFLG=1
 .W ! D DIR^KBAPXPDI("XPF",XPDFIL_"#") Q:$D(XPDQUIT)
 .S:$G(XPDQUES("XPF"_XPDFIL_"#2"))=0 $P(XPDANS,U,5)=1
 .S ^XTMP("XPDI",XPDA,"FIA",XPDFIL,0,2)=XPDANS
 .;kill the answers so we can re-ask for next file
 .F I=1:1:2 K XPDQUES("XPF"_XPDFIL_"#"_I)
 ;
 ;XPDQUIT is by file questions in previous do loop, set in XPDIQ
 I $D(XPDQUIT) D ASKABRT^XPDI Q
 ;
 ;ask for coordinators to incoming mail groups
 S (XPDFIL,XPDFLG)=0
 F  S XPDFIL=$O(^XTMP("XPDI",XPDA,"KRN",3.8,XPDFIL)) Q:'XPDFIL  S X=^(XPDFIL,0),Y=$G(^(-1)) D  Q:$D(XPDQUIT)
 .;XPDANS=Mail Group name
 .Q:$P(Y,U)=1  ;Don't ask if deleting
 .S XPDANS=$P(X,U)
 .I 'XPDFLG W !!,"Incoming Mail Groups:" S XPDFLG=1
 .W ! D DIR^KBAPXPDI("XPM",XPDFIL_"#") Q:$D(XPDQUIT)
 .;kill the answers so we can re-ask for next MG
 .K XPDQUES("XPM"_XPDFIL_"#1")
 .Q
 ;
 I $D(XPDQUIT) D ASKABRT^XPDI Q
 ;
 ;ask to rebuild menus if Option is added
 S (XPDFIL,XPDFLG)=0
 S XPDFIL=$O(^XTMP("XPDI",XPDA,"KRN",19,XPDFIL))  D:XPDFIL
 .S X=^XTMP("XPDI",XPDA,"KRN",19,XPDFIL,0)
 .;XPDANS=Menu Rebuild Answer
 .S XPDANS=$P(X,U)
 .W ! D DIR^KBAPXPDI("XPO") Q:$D(XPDQUIT)
 ;
 I $D(XPDQUIT) D ASKABRT^XPDI Q
 ;
 ;post-init questions
 W ! D DIR^KBAPXPDI("POS") I $D(DIRUT)!$D(XPDQUIT) D ASKABRT^XPDI Q
 Q
 ;
XQSET(XPDA) ;get options & protocols to disable
 ;put in ^TMP($J,"XQOO",starting build name)
 N A,I,X,Y
 S I=0 F  S I=$O(^XTMP("XPDI",XPDA,"KRN",19,I)) Q:'I  S X=^(I,0),A=^(-1) D
 .S Y=$O(^DIC(19,"B",$P(X,U),0))
 .;check that option exist and 0=send,1=delete,3=merge or 5=disable
 .I Y,$D(^DIC(19,Y,0)),$S('A:1,1:A#2) S ^TMP($J,"XQOO",XPDSET,19,Y)=$P(^(0),U,1,2)
 S I=0 F  S I=$O(^XTMP("XPDI",XPDA,"KRN",101,I)) Q:'I  S X=^(I,0),A=^(-1) D
 .S Y=$O(^ORD(101,"B",$P(X,U),0))
 .I Y,$D(^ORD(101,Y,0)),$S(A=3:1,A=5:1,1:'A) S ^TMP($J,"XQOO",XPDSET,101,Y)=$P(^(0),U,1,2)
 Q
 ;
 ; ==================== END OF XPDI1  =====================
 ;
EOR ;End of routine KBAPXPDI
 ;
