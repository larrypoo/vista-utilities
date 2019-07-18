KBAPXPDB ;ven/lgc - Backup installed Package ; 6/24/19 1:29pm
 ;;18.0;SAM;;
 ;
 ; From XPDIB
 ;SFISC/RSD - Backup installed Package ; 6/11/19 9:18am
 ;;8.0;KERNEL;**10,58,108,178**;Jul 10, 1995
 ;
START(pkgarr) ;
 quit:'$data(pkgarr)
 ; fall into modified XPDIB 
EN ;
 N XCNP,DIF,DIR,DIRUT,XMSUB,XMDUZ,XMDISPI,XMZ,XPD,XPDA,XPDNM,XPDQUIT,XPDST,XPDT,X,Y,%
 ;
 ;CHANGE ven/lgc load XPDT and XPDST variables
 ; XPDST=10216
 ; XPDT(1)="10216^DG*5.3*907"
 ; XPDT("DA",10216)=1
 ; XPDT("NM","DG*5.3*907")=1
 ;S %="I '$P(^(0),U,9),$D(^XPD(9.7,""ASP"",Y,1,Y)),$D(^XTMP(""XPDI"",Y))",XPDST=$$LOOK^XPDI1(%)
 ;Q:'XPDST!$D(XPDQUIT)
 ;
 set Y=$O(^XPD(9.7,"B",pkgarr("PatchToInstall"),0))
 if '$get(Y) write !,!,"**** Couldn't find "_pkgarr("PatchToInstall")_" in INSTALL file! ***",! quit
 ;
 set Y(0)=$get(^XPD(9.7,+Y,0))
 S XPD=+Y,XPDIT=0
 ;
 S XPDST=+Y
 ;
 W !!,"This Distribution was loaded on ",$$FMTE^XLFDT($P(Y(0),U,3))," with header of ",!?3,$G(^XPD(9.7,XPD,2)),!?3,"It consisted of the following Install(s):",!
 ;build XPDT array
 I '$D(^XPD(9.7,"ASP",XPD)) D XPDT^XPDI1(1,XPD) Q XPD
 F  S XPDIT=$O(^XPD(9.7,"ASP",XPD,XPDIT)) Q:'XPDIT  S Y=+$O(^(XPDIT,0)) D XPDT^XPDI1(XPDIT,Y)
 ;
 ;CHANGE ven/lgc - no human interaction
 ;S DIR(0)="F^3:65"
 ;S DIR("A")="Subject"
 ;S DIR("?")="characters and must not contain embedded uparrow."
 ;S DIR("?",1)="Enter the subject for this Packman Backup Message"
 ;S DIR("?",2)="This response must have at least 3 characters and no more than 63"
 ;S DIR("B")=$E(("Backup of "_$P(XPDT(1),U,2)_" install on "_$$FMTE^XL;FDT(DT)),1,63)
 ;D ^DIR I $D(DIRUT) D QUIT^XPDI1(XPDST) Q
 ;
ENDBG set X="Backup of "_pkgarr("ptchstrg")_" on "_$$HTE^XLFDT($H)
 set Y=X
 ;
 S XMSUB=Y,XMDUZ=+DUZ
 D XMZ^XMA2 I XMZ<1 D QUIT^XPDI1(XPDST) Q
 S Y=$$NOW^XLFDT,%=$$DOW^XLFDT(Y),Y=$$FMTE^XLFDT(Y,2)
 S X="PACKMAN BACKUP Created on "_%_", "_$P(Y,"@")_" at "_$P(Y,"@",2)
 ;
 n KBAPBMSG S KBAPBMSG=X
 ;
 I $D(^VA(200,DUZ,0)) S X=X_" by "_$P(^(0),U)_" "
 S:$D(^XMB("NAME")) X=X_"at "_$P(^("NAME"),U)_" "
 S ^XMB(3.9,XMZ,2,0)="^3.92A^^^"_DT,^(1,0)="$TXT "_X,XCNP=1
 S XPDT=0
 F  S XPDT=$O(XPDT(XPDT)) Q:'XPDT  D
 .S XPDA=+XPDT(XPDT),XPDNM=$P(XPDT(XPDT),U,2),XPD=""
 .I '$D(^XTMP("XPDI",XPDA,"RTN")) W !,"No routines for ",XPDNM,! Q
 .W !,"Loading Routines for ",XPDNM
 .F  S XPD=$O(^XTMP("XPDI",XPDA,"RTN",XPD)) Q:XPD=""  D ROU(XPD) W "."
 ;
 ; Don't ask user or basket
 ;   *** understood user must have KIDS basket
 ;
 set XMY(DUZ)=0,XMY(DUZ,0)="KIDS"
 ;
 D EN3^XMD,QUIT^XPDI1(XPDST)
 ;
 W !,!,KBAPBMSG,!,"Completed.",!
 ;
 Q
 ;
ROU(X) N %N,DIF
 X ^%ZOSF("TEST") E  W !,"Routine ",X," is not on the disk." Q
 S XCNP=XCNP+1,^XMB(3.9,XMZ,2,XCNP,0)="$ROU "_X_" (PACKMAN_BACKUP)",DIF="^XMB(3.9,XMZ,2,"
 X ^%ZOSF("LOAD")
 S $P(^XMB(3.9,XMZ,2,0),U,3,4)=XCNP_U_XCNP,^(XCNP,0)="$END ROU "_X_" (PACKMAN-BACKUP)"
 Q
 ;
EOR ; End of routine KBAPXPDB
