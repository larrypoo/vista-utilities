KBAPHL7A ;KBAP/lgc- GUI HL7 VIEWER UTILITY ;Sep 21, 2019@15:28
 ;;1.6;HEALTH LEVEL SEVEN;; Sept 21, 2019;Build 8
 ;
 ; Routine to hold code for RPC calls feeding the Delphi
 ;   gui HL7 application
 ;
 ;   *** Remote procedure entry
 ;       KBAP HL7VIEWER USERID
 ;
IDUSER(XDATA) ;
 K XDATA
 Q:'DUZ
 S XDATA=DUZ_U_$P($G(^VA(200,DUZ,0)),U)_U
 N KEY S KEY=+$O(^DIC(19.1,"B","KBAP HL7VIEW SNDMSG",0))
 S:KEY KEY=$D(^VA(200,DUZ,51,KEY,0))
 S:KEY XDATA=XDATA_"KBAP HL7VIEW SNDMSG"_U
 D GETENV^%ZOSV
 S $P(XDATA,U,4)=$P(Y,U)
 S XDATA=XDATA_U
 Q
 ;
 ;   *** Remote procedure entry
 ;       KBAP HL7VIEWER LASTNMSH
 ;
 ; Return the most recent N HL7 OR HLO MSH headers
 ;
RTNHL7(XLIST,HLIEN,HL7HLO,NMBR) ;
 K XLIST
 N XMSH
 N RTN S RTN=$T(+0)
 K ^XTMP(RTN) S ^XTMP(RTN)="HLIEN="_$G(HLIEN)_" HL7HLO="_$G(HL7HLO)
 S ^XTMP(RTN)=^XTMP(RTN)_" NMBR="_$G(NMBR)
 ; We will look for HL7 unless specifically told to do HLO
 I ($G(HL7HLO)="") S HL7HLO="HL7"
 I ($L(HL7HLO)'=3) S HL7HLO="HL7"
 I "/HL7/HLO"'[HL7HLO S HL7HLO="HL7"
 S NMBR=+$G(NMBR) I NMBR>100 S NMBR=100
 N CNT S CNT=1
 I +$G(HLIEN)=0 S HLIEN="A"
 I HL7HLO["HLO" G RTNHLO
 F  S HLIEN=$O(^HLMA(HLIEN),-1) Q:'HLIEN  D  Q:CNT>NMBR
 . K XMSH
 . D GETS^DIQ(773,HLIEN_",",200,"","XMSH")
 .; MOD 1/16/2014 to prevent error where no 1 node exists
 . I $D(XMSH)#2 D
 ..  S CNT=CNT+1,XLIST(CNT)=HLIEN_U_XMSH(773,HLIEN_",",200,1)
 ..  S XLIST(1)=HLIEN
 Q
RTNHLO ;
 F  S HLIEN=$O(^HLB(HLIEN),-1) Q:'HLIEN  D  Q:CNT>NMBR
 .  K XMSH
 .  D GETS^DIQ(778,HLIEN_",","1:3","","XMSH")
 .  I $D(XMSH)#2 D
 ..  S CNT=CNT+1
 ..  S XLIST(CNT)=HLIEN_U_$G(XMSH(778,HLIEN_",",1))
 ..  S XLIST(CNT)=XLIST(CNT)_$G(XMSH(778,HLIEN_",",2))
 ..  S XLIST(CNT)=XLIST(CNT)_$G(XMSH(778,HLIEN_",",3))
 ..  S XLIST(1)=HLIEN
 Q
 ;
 ;   *** Remote procedure entry
 ;       KBAP HL7VIEWER SEARCH MSGS
 ;
 ;  SRCHTXT   = TEXT TO SEARCH FOR
 ;  HLIEN     = IEN INTO 773 OR 778
 ;  MAXCNT    = LIMIT SEARCH TO THIS MANY MATCHES
 ;  SRCHSEG   = SEGMENT TO SEARCH
 ;  HL7HLO    = "HL7" OR "HLO" INDICATING MESSAGE TYPE
 ;
SRCHHL7(XLIST,SRCHTXT,HLIEN,MAXCNT,SRCHSEG,HL7HL0) ;
 N RTN S RTN=$T(+0)
 K ^XTMP(RTN,$J),^XTMP(RTN,DUZ,$J)
 S ^XTMP(RTN,DUZ,$J)="SRCHTXT="_$G(SRCHTXT)_" HLIEN="_$G(HLIEN)
 S ^XTMP(RTN,DUZ,$J)=^XTMP(RTN,DUZ,$J)_" MAXCNT="_$G(MAXCNT)
 S ^XTMP(RTN,DUZ,$J)=^XTMP(RTN,DUZ,$J)_" SRCHSEG="_$G(SRCHSEG)
 S ^XTMP(RTN,DUZ,$J)=^XTMP(RTN,DUZ,$J)_" HL7HLO="_$G(HL7HLO)
 K XLIST
 I $G(HL7HLO)'["HLO" S HL7HLO="HL7"
 S SRCHTXT=$G(SRCHTXT,"")
 N STOPIT S STOPIT=0
 N STOPTIME S STOPTIME=$P($H,",",2)
 N TXTKEY S TXTKEY=$E($P(SRCHTXT,U)_"9999999999999999999",1,20)
 S HLIEN=$S($G(HLIEN)>0:+HLIEN,1:"A")
 N XIEN ; Variable to save last IEN searched
 ;
 N CNT S CNT=0 ; Counting variable for looping
 ;
 ; Decide if we are only searching MSH or searching body of msg
 I $G(SRCHSEG)'["MSH" G SRCHBODY
 S ^XTMP(RTN,DUZ,$J,"SRCHMSH")="DOING MSH SEARCH. HLIEN/HL7HLO="_$G(HLIEN)_"/"_$G(HL7HLO)
 ;
 ; OK.  We are only searching the MSH header
 ; Only question left is are we searching HL7 or HLO
 I HL7HLO["HLO" G HLOMSH
 ; OK  We are searching HL7 MSH headers
HL7MSH ; Request is for HL7 MSH search
 S XIEN=HLIEN
 F  S HLIEN=$O(^HLMA(HLIEN),-1) G:'HLIEN EXITMSH D  G:STOPIT EXITMSH
 . S XIEN=HLIEN
 . I $G(^HLMA(HLIEN,"MSH",1,0))[SRCHTXT D
 .. S CNT=CNT+1 I CNT>MAXCNT S STOPIT=1 Q
 ..; MOD 1/16/2014 to prevent error with missing MSH
 .. I $D(^HLMA(HLIEN,"MSH",1,0)) D
 ... S ^XTMP(RTN,$J,"MSHSRCH",TXTKEY,HLIEN)=HLIEN_U_^HLMA(HLIEN,"MSH",1,0)_U
 . I $P($H,",",2)-STOPTIME>20 D
 .. S STOPIT=1
 Q
HLOMSH ; We are searching HLO MSH headers
 S XIEN=HLIEN
 F  S HLIEN=$O(^HLB(HLIEN),-1) G:'HLIEN EXITMSH D  G:STOPIT EXITMSH
 . S XIEN=HLIEN
 . I ($G(^HLB(HLIEN,1))[SRCHTXT)!($G(^HLB(HLIEN,2))[SRCHTXT) D
 .. S CNT=CNT+1 I CNT>MAXCNT S STOPIT=1 Q
 .. S ^XTMP(RTN,$J,"MSHSRCH",TXTKEY,HLIEN)=HLIEN_U_$G(^HLB(HLIEN,1))_$G(^HLB(HLIEN,2))_U
 . I ($P($H,",",2)-STOPTIME)>20 D
 .. S STOPIT=1
 ;
EXITMSH M XLIST=^XTMP(RTN,$J,"MSHSRCH",TXTKEY)
 S XLIST(1)=XIEN
 ;
 Q
 ;
 ; OK.  SRCHSEG did not have MSH in it so search all body segments
 ;   for SRCHTXT if SRCHSEG="" or just the segment in SRCHSEG
 ;
SRCHBODY ;
 S ^XTMP(RTN,DUZ,$J,"SRCHBODY")="DOING BODY SEARCH. HLIEN/HL7HLO="_$G(HLIEN)_"/"_$G(HL7HLO)
 I HL7HLO["HLO" G SEGHLO
SEGHL7 ;
 F  S HLIEN=$O(^HLMA(HLIEN),-1) G:'HLIEN EXITSEGS D  G:STOPIT EXITSEGS
 . I ($P($H,",",2)-STOPTIME)>20 S STOPIT=1
 . S ^XTMP(RTN,$J,"SEGSRCH",0)=HLIEN
 . I $$SEGMATCH(HLIEN,SRCHTXT,SRCHSEG,HL7HLO) D
 .. S ^XTMP(RTN,$J,"SEGSRCH",HLIEN)=HLIEN_U_^HLMA(HLIEN,"MSH",1,0)_U
 .. S CNT=CNT+1 I CNT>MAXCNT S STOPIT=1
 ;
SEGHLO ;
 F  S HLIEN=$O(^HLB(HLIEN),-1) G:'HLIEN EXITSEGS D  G:STOPIT EXITSEGS
 . I ($P($H,",",2)-STOPTIME)>20 S STOPIT=1
 . S ^XTMP(RTN,$J,"SEGSRCH",0)=HLIEN
 . I $$SEGMATCH(HLIEN,SRCHTXT,SRCHSEG,HL7HLO) D
 .. S ^XTMP(RTN,$J,"SEGSRCH",HLIEN)=HLIEN_U_$G(^HLB(HLIEN,1))_$G(^HLB(HLIEN,2))_U
 .. S CNT=CNT+1 I CNT>MAXCNT S STOPIT=1
 ;
EXITSEGS ;
 M XLIST=^XTMP(RTN,$J,"SEGSRCH")
 Q
 ;
 ; Look for match in the text body of the message within the
 ;  requested SEGMENT.  If the search string is empty then
 ;  any message with the selected SEGMENT meets the critera.
 ; Of course we have to look through HL7 differently than HL0
 ;  messages
SEGMATCH(HLIEN,SRCHTXT,SRCHSEG,HL7HLO) ;
 N MATCH S MATCH=0
 N SUBS1,SUBS2,SEGNODE,CMPLTSEG
 S (SUBS1,SUBS2,SEGNODE,CMPLTSEG)=""
 I $L($G(HLIEN))=0 Q MATCH
 I HL7HLO["HLO" D  Q MATCH
 . N HL777IEN S HL777IEN=+$P($G(^HLB(HLBIEN,0)),U,2)
 . S SUBS1=0
 . F  S SUBS1=$O(^HLA(HL777IEN,1,SUBS1)) Q:$L(SUBS1)=0  D  Q:MATCH
 .. S SEGNODE=$G(^HLA(HL777IEN,1,SUBS1,0))
 .. I $L($TR(SEGNODE," ")) D  Q
 ... S CMPLTSEG=CMPLTSEG_SEGNODE
 .. I $L(CMPLTSEG) D  Q
 ... S MATCH=$$SEGTXT(CMPLTSEG,SRCHSEG,SRCHTXT)
 ... I MATCH S ^XTMP(RTN,CMPLTSEG)=MATCH_U_$G(SRCHSEG)_U_$G(SRCHTXT)
 ... S CMPLTSEG=""
 ;
 I HL7HLO'["HLO" D  Q MATCH
 . N HL772IEN S HL772IEN=+$G(^HLMA(HLIEN,0))
 . F  S SUBS1=$O(^HL(772,HL772IEN,SUBS1)) Q:$L(SUBS1)=0  D  Q:MATCH
 .. S SUBS2=0
 .. F  S SUBS2=$O(^HL(772,HL772IEN,SUBS1,SUBS2)) Q:'SUBS2  D  Q:MATCH
 ... S SEGNODE=$G(^HL(772,HL772IEN,SUBS1,SUBS2,0))
 ... I $L($TR(SEGNODE," ")) D  Q
 .... S CMPLTSEG=CMPLTSEG_SEGNODE
 ... I $L(CMPLTSEG) D  Q
 .... S MATCH=$$SEGTXT(CMPLTSEG,SRCHSEG,SRCHTXT)
 .... I MATCH S ^XTMP(RTN,CMPLTSEG)=MATCH_U_$G(SRCHSEG)_U_$G(SRCHTXT)
 .... S CMPLTSEG=""
 ;
SEGTXT(CMPLTSEG,SRCHSEG,SRCHTXT) ;
 ;
 I $E(CMPLTSEG,1,3)=SRCHSEG,$L(SRCHTXT)=0 Q 1
 I $E(CMPLTSEG,1,3)=SRCHSEG,CMPLTSEG[SRCHTXT Q 1
 I $L(SRCHSEG)<3,CMPLTSEG[SRCHTXT Q 1
 Q 0
 ;
 ;
 ;   *** Remote procedure entry
 ;       KBAP HL7VIEWER MSG BODY
 ;
 ; Enter with MSH header IEN into file 773
 ;   and return an array with the main body of the
 ;   associated entry in file 772
 ;
BODY(XLIST,MSHIEN) ;
 K XLIST
 Q:'MSHIEN
 N BODYIEN S BODYIEN=+$G(^HLMA(MSHIEN,0))
 Q:'BODYIEN
 N TMPLST
 M TMPLST=^HL(772,BODYIEN,"IN")
 N CNT S CNT=0
 F  S CNT=$O(TMPLST(CNT)) Q:'CNT  D
 . S XLIST(CNT)=$G(TMPLST(CNT,0))
 K ^XTMP("KBAPHL7","BODY")
 M ^XTMP("KBAPHL7","BODY")=XLIST
 Q
 ;
 ;   *** Remote procedure entry
 ;       KBAP HL7VIEWER HLPRS CALL
 ;
HLPRS(XLIST,MSHIEN) ; VISTA HLPRS HL7 MSH HEADER PARSING
 K XLIST
 Q:'MSHIEN
 N RTN S RTN=$T(+0)
 N HLMSG,HEADER,SEG
 K ^XTMP(RTN,"HLMSG"),^XTMP(RTN,"HEADER")
 I $$STARTMSG^HLPRS(.HLMSG,+MSHIEN,.HEADER) D
 .  M ^XTMP(RTN,"HLMSG")=HLMSG
 .  M ^XTMP(RTN,"HEADER")=HEADER
 .  N NODE S NODE=$NA(^XTMP(RTN,"HEADER"))
 .  N STOPNODE S STOPNODE=$P(NODE,")")
 .  N CNT S CNT=0
 .  F  S NODE=$Q(@NODE) Q:NODE'[STOPNODE  D  Q:CNT>100
 ..  S CNT=CNT+1,XLIST(CNT)=$P($P(NODE,",",3,5),")")
 ..  S XLIST(CNT)=XLIST(CNT)_"%^%"_@NODE
 Q
 ;
 ;    ***** Remote Procedure Entry
 ;   KBAP HL7VIEWER EVNT VARS
 ;
EVNTVARS(XLIST,ORDIEN) ;
 K XLIST
 Q:'ORDIEN
 N HL,HLECH,HLFS,HLQ,SUB
 D INIT^HLFNC2(ORDIEN,.HL)
 N CNT S CNT=1
 S XLIST(CNT)="HL="_$G(HL)
 S SUB="" F  S SUB=$O(HL(SUB)) Q:SUB=""  D
 . S CNT=CNT+1,XLIST(CNT)="HL("""_SUB_""")="_HL(SUB)
 S CNT=CNT+1,XLIST(CNT)="HLECH="_$G(HLECH)
 S CNT=CNT+1,XLIST(CNT)="HLFS="_$G(HLFS)
 S CNT=CNT+1,XLIST(CNT)="HLQ="_$G(HLQ)
 Q
 ;
 ;    ***** Remote Procedure Entry
 ;   KBAP HL7VIEWER PROT4APP
 ;
 ;  APPL = APPLICATION NAME
 ;  SNDREC = "SEND" OR "REC"
 ;
PROTLINK(XLIST,APPL,SNDREC) ;
 K XLIST
 Q:'$D(APPL)
 N APPLIEN S APPLIEN=$O(^HL(771,"B",APPL,0))
 Q:'APPLIEN
 Q:'$D(SNDREC)
 Q:'("/SEND/REC/"[SNDREC)
 D @SNDREC
 Q
 ;
SEND ;
 N AHL21ND,NAME,PROTIEN,XPROT
 N CNT S CNT=0
 S AHL21ND=$NA(^ORD(101,"AHL21",APPLIEN))
 F  S AHL21ND=$Q(@AHL21ND) Q:AHL21ND'[("""AHL21"","_APPLIEN)  D
 . S PROTIEN=$P($P(AHL21ND,",",6),")")
 . K XPROT D GETS^DIQ(101,PROTIEN_",","**","","XPROT")
 . I $D(XPROT) D
 .. S NAME=XPROT(101,PROTIEN_",",.01)
 .. S CNT=CNT+1,XLIST(CNT)="SENDING APPLICATION : "_APPL_" ["_APPLIEN_"]"
 .. S CNT=CNT+1,XLIST(CNT)="   PROTOCOL NAME : "_NAME_" ["_PROTIEN_"]"
 .. S CNT=CNT+1,XLIST(CNT)="   EVENT DRIVER TYPE : "_XPROT(101,PROTIEN_",",4)
 .. S CNT=CNT+1,XLIST(CNT)="   TRANSACTION MESSAGE TYPE : "_XPROT(101,PROTIEN_",",770.3)
 .. S CNT=CNT+1,XLIST(CNT)="   MESSAGE STRUCTURE : "_XPROT(101,PROTIEN_",",770.4)
 .. S CNT=CNT+1,XLIST(CNT)="   ACCEPT ACK CODE : "_XPROT(101,PROTIEN_",",770.8)
 .. S CNT=CNT+1,XLIST(CNT)="   APPLICATION ACK TYPE : "_XPROT(101,PROTIEN_",",770.9)
 .. S CNT=CNT+1,XLIST(CNT)="   VERSION ID : "_XPROT(101,PROTIEN_",",770.95)
 ..; Now get any subscribers
 .. K XPROT D GETS^DIQ(101,PROTIEN_",","775*","IE","XPROT")
 .. I $D(XPROT) S NODE="XPROT" F  S NODE=$Q(@NODE) Q:NODE'["XPROT"  D
 ... I '@NODE S CNT=CNT+1,XLIST(CNT)="    SUBSCRIBER : "_@NODE
 ... E  S XLIST(CNT)=XLIST(CNT)_" ["_@NODE_"]"
 . S CNT=CNT+1 S XLIST(CNT)="  "
 Q
 ;
REC ;
 N AHL2ND,CNT,NAME,XPROT,PROTIEN
 S CNT=0
 S AHL2ND=$NA(^ORD(101,"AHL2",APPLIEN))
 F  S AHL2ND=$Q(@AHL2ND) Q:AHL2ND'[("""AHL2"","_APPLIEN)  D
 . S PROTIEN=$P($P(AHL2ND,",",4),")")
 . K XPROT D GETS^DIQ(101,PROTIEN_",","**","IE","XPROT")
 . S NAME=XPROT(101,PROTIEN_",",.01,"E")
 . S CNT=CNT+1,XLIST(CNT)="RECEIVING APPLICATION : "_APPL_" ["_APPLIEN_"]"
 . S CNT=CNT+1,XLIST(CNT)="  PROTOCOL NAME : "_NAME_" ["_PROTIEN_"]"
 . S CNT=CNT+1,XLIST(CNT)="  TYPE : "_$G(XPROT(101,PROTIEN_",",4))
 . S CNT=CNT+1,XLIST(CNT)="  EVENT TYPE : "_XPROT(101,PROTIEN_",",770.4,"E")
 .; Get logical link if one is associated with protocol
 . I $G(XPROT(101,PROTIEN_",",770.7,"I")) D
 .. N LOGLINK S LOGLINK=XPROT(101,PROTIEN_",",770.7,"I")
 .. N XLOGL D GETS^DIQ(870,LOGLINK_",","**","IE","XLOGL")
 .. S CNT=CNT+1,XLIST(CNT)="   LOGICAL LINK : "_XLOGL(870,LOGLINK_",",.01,"E")_" ["_LOGLINK_"]"
 .. S CNT=CNT+1,XLIST(CNT)="      INSTITUTION : "_$G(XLOGL(870,LOGLINK_",",.02,"E"))
 .. S CNT=CNT+1,XLIST(CNT)="      LLP TYPE : "_$G(XLOGL(870,LOGLINK_",",2,"E"))
 .. S CNT=CNT+1,XLIST(CNT)="      STATE : "_$G(XLOGL(870,LOGLINK_",",4,"E"))
 .. S CNT=CNT+1,XLIST(CNT)="      DNS DOMAIN : "_$G(XLOGL(870,LOGLINK_",",.08,"E"))
 .. S CNT=CNT+1,XLIST(CNT)="      TCP/IP ADDRESS : "_$G(XLOGL(870,LOGLINK_",",400.01,"E"))
 .. S CNT=CNT+1,XLIST(CNT)="      TCP/IP PORT : "_$G(XLOGL(870,LOGLINK_",",400.02,"E"))
 .; Now getthe rest of the protocol data
 . S CNT=CNT+1,XLIST(CNT)="   RESPONSE MESSAGE TYPE : "_$G(XPROT(101,PROTIEN_",",771.2,"E"))
 . S CNT=CNT+1,XLIST(CNT)="   PROCESSING ROUTINE : "_$G(XPROT(101,PROTIEN_",",771,"E"))
 . S CNT=CNT+1,XLIST(CNT)="   SENDING FACILITY REQUIRED : "_$G(XPROT(101,PROTIEN_",",773.1,"E"))
 . S CNT=CNT+1,XLIST(CNT)="   RECEIVING FACILITY REQUIRED : "_$G(XPROT(101,PROTIEN_",",773.2,"E"))
 . S CNT=CNT+1,XLIST(CNT)="  "
 Q
 ;
 ;
 ;    ***** Remote Procedure Entry
 ;   KBAP HL7VIEWER EVENT PROTOCOLS
 ;
EVNTPROT(XLIST) ;
 K XLIST
 N ORDIEN,SNDAPP,SNDAPPI,SNDAPPE
 N NODE S NODE=$NA(^ORD(101,"AHL21"))
 N STOPNODE S STOPNODE=$P(NODE,")")
 F  S NODE=$Q(@NODE) Q:NODE'[STOPNODE  D
 . I $P($G(^ORD(101,$P($P(NODE,",",6),")"),0)),U,4)["E" D
 .. S ORDIEN=$P($P(NODE,",",6),")")
 .. S SNDAPPI=$$GET1^DIQ(101,ORDIEN_",","770.1","I")
 .. S SNDAPPE=$$GET1^DIQ(101,ORDIEN_",","770.1","E")
 .. S XLIST(ORDIEN)=$$GET1^DIQ(101,ORDIEN_",",.01)_U_ORDIEN_U_SNDAPPE_U_SNDAPPI_U
 Q
 ;
 ;    ***** Remote Procedure Entry
 ;   KBAP HL7VIEWER GET MSHTEXT
 ;
GETMTXT(XLIST,HLIEN,HL7HLO) ;
 K XLIST
 S:($G(HL7HLO)'["HLO") HL7HLO="HL7"
 Q:'HLIEN
 N NODE,HL777IEN,HL772IEN
 I HL7HLO["HLO" D  Q
 . S NODE=$NA(^HLB(HLIEN))
 . F  S NODE=$Q(@NODE) Q:NODE'[HLIEN  D
 ..  S XLIST=$G(XLIST)+1
 ..  I XLIST=1 S HL777IEN=$P(@NODE,U,2)
 ..  S XLIST(XLIST)=NODE_"="_@NODE
 . S XLIST=XLIST+1
 . S XLIST(XLIST)="HL777DATA STARTS"
 . S NODE=$NA(^HLA(HL777IEN))
 . F  S NODE=$Q(@NODE) Q:NODE'[HL777IEN  D
 .. S XLIST=XLIST+1
 .. S XLIST(XLIST)=NODE_"="_@NODE
 ;
 ; looking for HL7 message
 ;
 S NODE=$NA(^HLMA(HLIEN))
 F  S NODE=$Q(@NODE) Q:NODE'[HLIEN  D
 . S XLIST=$G(XLIST)+1
 . I XLIST=1 S HL772IEN=+@NODE
 . S XLIST(XLIST)=NODE_"="_@NODE
 S XLIST=XLIST+1
 S XLIST(XLIST)="HL772DATA STARTS"
 S NODE=$NA(^HL(772,HL772IEN))
 F  S NODE=$Q(@NODE) Q:NODE'[HL772IEN  D
 . S XLIST=XLIST+1
 . S XLIST(XLIST)=NODE_"="_@NODE
 Q
EOF ; End of routine KBAPHL7A
