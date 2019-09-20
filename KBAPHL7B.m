KBAPHL7B        ;KBAP/lgc - GUI HL7 VIEWER UTILITY ; 9/20/2019 10:13 AM
        ;;1.0;KBAP;;
        ;
        ; KBAPHL7 continued
        ; Remote procedures for HL7VIEWER
        ;
        ;    ***** Remote Procedure Entry
        ;          KBAP HL7VIEW GENERATE MSG
        ;
GENHL7(XTEXT,EVNTIEN,MSGBODY)   ;
        N RTN S RTN=$T(+0)
        K ^XTMP(RTN)
        S ^XTMP(RTN,$J,"EVNTIEN")=$G(EVNTIEN)
        M ^XTMP(RTN,$J,"MSGBODY")=MSGBODY
        ;
        ;
        K HLA,HLEVN
        K XTEXT S XTEXT="0"_U_"Need Text Body"
        Q:'$D(MSGBODY)
        S XTEXT="0"_U_"Need Event Protocol IEN"
        Q:'EVNTIEN
        Q:'$D(^ORD(101,EVNTIEN,0))
        Q:'($P($G(^ORD(101,EVNTIEN,0)),U,4)="E")
        N EVNTNAME S EVNTNAME=$P($G(^ORD(101,EVNTIEN,0)),U)
        ; Now set up the environment for a message using
        ;   VistA API
        N HLFS,HLCS
        D INIT^HLFNC2(EVNTNAME,.HL)
        I $G(HL) D  Q
        .  S XTEXT="0"_U_"INIT_HLFNC2 FAILED FOR EVENT PROTOCOL "
        .  S XTEXT=XTEXT_EVNTNAME_" "_$P(HL,U,2)
        S HLFS=$G(HL("FS")) I HLFS="" S HLFS="^"
        S HLCS=$E(HL("ECH"),1)
        ;
        ; Now add message body to HLA array
        ;
        N BCNT,HL,HLA1CNT,HLA2CNT,CNT
        S (HLA1CNT,HLA2CNT,CNT)=0
        F  S CNT=$O(MSGBODY(CNT)) Q:'CNT  D
        .; Note that a blank line means no longer building a long seg
        .;  so just advance counter
        .  I $L(MSGBODY(CNT))=0 D  Q
        ..  S HLA2CNT=0
        .; Non blank line.  Since second suscript not zero save long
        .;  segment continuation to secondary array
        .  I HLA2CNT>0 D  Q
        ..  S HLA("HLS",HLA1CNT,HLA2CNT)=MSGBODY(CNT)
        ..  S HLA2CNT=HLA2CNT+1
        .; Non blank line and secondary subscript is 0 so new segment
        .  S HLA1CNT=HLA1CNT+1
        .  S HLA("HLS",HLA1CNT)=MSGBODY(CNT)
        .  S HLA2CNT=1
        ;
        ; Now call HL7 generation API and return message
        N MYRESULT
        D GENERATE^HLMA(EVNTNAME,"LM",1,.MYRESULT)
        S XTEXT=MYRESULT
        Q
        ;
        ;    ***** Remote Procedure Entry
        ;          KBAP HL7VIEW LOGICAL LINKS
        ;
LOGLINKS(XDATA) ;
        K XDATA
        N SENDAPP,RECVAPP,LOGLINK,LL,NODE770
        N ORDIEN S ORDIEN=0
        F  S ORDIEN=$O(^ORD(101,ORDIEN)) Q:'ORDIEN  D
        .  S (SENDAPP,RECVAPP)=0
        .  S NODE770=$G(^ORD(101,ORDIEN,770)) Q:NODE770=""  D
        ..  S LOGLINK=$P(NODE770,U,7) I LOGLINK D
        ...  S SENDAPP=$P(NODE770,U) I SENDAPP D
        ....  D LL1(LOGLINK,SENDAPP,0)
        ...  S RECVAPP=$P(NODE770,U,2) I RECVAPP D
        ....  D LL1(LOGLINK,0,RECVAPP)
        Q
LL1(LOGLINK,SENDAPP,RECVAPP)    ;
        S LOGLINK=$P($G(^HLCS(870,LOGLINK,0)),U) Q:($L(LOGLINK)=0)
        I SENDAPP D
        .  S SENDAPP=$P($G(^HL(771,SENDAPP,0)),U)
        .  I '$D(LL(LOGLINK,SENDAPP)) D
        ..  S LL(LOGLINK,SENDAPP)=""
        ..  S XDATA=$G(XDATA)+1,XDATA(XDATA)=LOGLINK_" ~ S ~ "_U_SENDAPP_U
        I RECVAPP D
        .  S RECVAPP=$P($G(^HL(771,RECVAPP,0)),U)
        .  I '$D(LL(LOGLINK,RECVAPP)) D
        ..  S LL(LOGLINK,RECVAPP)="" D
        ..  S XDATA=$G(XDATA)+1,XDATA(XDATA)=LOGLINK_" ~ R ~ "_U_RECVAPP_U
        Q
        ;
        ;    ***** Remote Procedure Entry
        ;          KBAP HL7VIEW SEGTYPES
SEGTYPES(XDATA) ;
        K XDATA
        N CNT,SEGIEN,SEGNAME,SEGABB S SEGABB=""
        F  S SEGABB=$O(^HL(771.3,"B",SEGABB)) Q:SEGABB=""  D
        .  S SEGIEN=$O(^HL(771.3,"B",SEGABB,0))
        .  S SEGNAME=$P($G(^HL(771.3,SEGIEN,0)),U,2)
        .  S CNT=$G(CNT)+1
        .  S XDATA(CNT)=SEGABB_U_SEGNAME_U
        Q
        ;    ***** Remote Procedure Entry
        ;          KBAP HL7VIEWER GET HL7 TITLES
        ;
MSGTITLS(XLIST) ;
        K XLIST
        N TITIEN S TITIEN=0
        F  S TITIEN=$O(^DIZ(840201100,TITIEN)) Q:'TITIEN  D
        .  S XLIST(TITIEN)=$P($G(^DIZ(840201100,TITIEN,0)),U)_U_TITIEN_U
        Q
        ;
        ;    ***** Remote Procedure Entry
        ;          KBAP HL7VIEWER GET SAVED MSG
        ;
GETMSG(XLIST,NAMEIEN)   ;
        K XLIST
        Q:'NAMEIEN
        Q:'$D(^DIZ(840201100,NAMEIEN))
        N TMPSTR
        D GETS^DIQ(840201100,NAMEIEN_",","1","E","TMPSTR")
        M XLIST=TMPSTR(840201100,""_NAMEIEN_",",1)
        K XLIST("E")
        Q
        ;
        ;    ***** Remote Procedure Entry
        ;          KBAP HL7VIEWER SAVE/UPDATE MSG
        ;
        ; Enter with
        ;   LIST    = array of text to file
        ;   NAME    = name or title for message to be saved
        ;   NAMEIEN = IEN into file 840201100 if updating existing entry
        ;
        ; Note : not using "B" cross to avoid 30 character issue
SAVUPMSG(XERR,LIST,NAME,NAMEIEN)        ;
        K ^TMP("DIERR",$J),DIERR
        N RTN S RTN=$T(+0)
        K ^XTMP(RTN,$J)
        ; debug
        M ^XTMP(RTN,$J)=LIST
        S ^XTMP(RTN,$J,"NAME")=$G(NAME)
        S ^XTMP(RTN,$J,"NAMEIEN")=$G(NAMEIEN)
        N FMDATE S FMDATE=$$DT^XLFDT
        S XERR=$NA(^TMP("DIERR",$J))
SVU1    I (('$G(NAMEIEN))&('$D(NAME))) D  Q
        .  S ^TMP("DIERR",$J,1)="Missing Name and Name IEN"
SVU2    I '$D(LIST) D  Q
        .  S ^TMP("DIERR",$J,1)="No text sent for filing"
        ;
        ; A new entry will not have been sent with the NAMEIEN
        I '$G(NAMEIEN) D  Q:$D(DIERR)
        .  N KBAPFDA,KBAPIEN
        .  S KBAPFDA(840201100,"+1,",.01)=NAME
        .  D UPDATE^DIE("","KBAPFDA","KBAPIEN","")
        .  S NAMEIEN=$G(KBAPIEN(1))
        ;
        ; OK We know the entry now exists so save text in LIST
        ;   whether new or overwriting earlier text
SVU3    N CNT S CNT=$O(LIST("A"),-1)
        D WP^DIE(840201100,+NAMEIEN_",",1,"K","LIST")
        Q
