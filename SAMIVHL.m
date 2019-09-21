SAMIVHL ;SAMI/lgc - HL7 TIU processing for VAPALS ;Sep 20, 2019@20:54
 ;;18.0;SAMI;
 ;
 quit ; no entry from top
 ;
 ;
EN ;
 N DIQUIET,HLA,HLL,HLP,X,Y
 ; Prevent FileMan from issuing any unwanted WRITE(s).
 S (DIQUIET,LRQUIET)=1
 ; Insure DT and DILOCKTM is defined
 D DT^DICRW
 ;
 K ^TMP("HLA",$J)
 ;
 ; Temp for debug SAMI TIU SEND SUBSCR is IEN 5170
 D INIT^HLFNC2(5170,.HL)
 S HL("EIDS")=5170
 ;
 ;
 ;---------- PREPARE FOR SENDING ACK/NAK --------------------------
 ;
 ; Set up LA7HLS with HL variables to build ACK message.
 ; Handle situation when systems use different encoding characters.
 ; NOTE: HL("EIDS") is setup when HL7 received.  This is the
 ;   name or IEN of the subscriber protocol
 D RSPINIT^HLFNC2(HL("EIDS"),.LA7HLS)
 ;
 ; Move message from HL7 global to Lab global
 F LA7VI=1:1 X HLNEXT Q:HLQUIT'>0  D  Q:$G(VGTMRTSK)
 . K LA7SEG,LA7STYP
 . I HLNODE="" Q
 . S LA7SEG(0)=HLNODE,LA7STYP=$E(LA7SEG(0),1,3)
 .; Catch comments > 245 characters
 . I $D(HLNODE(1)) S LA7SEG(0)=LA7SEG(0)_HLNODE(1)
 . I LA7STYP'?2U1UN D
 . . S LA7ERR=34,LA7AERR=$$CREATE^LA7LOG(LA7ERR,1)
 . . D REJECT($P(LA7AERR,"^",2))
 . S LA7VJ=0
 . F  S LA7VJ=$O(HLNODE(LA7VJ)) Q:'LA7VJ  S LA7SEG(LA7VJ)=HLNODE(LA7VJ)
 . I LA7STYP="MSH" D MSH Q:$G(VGTMRTSK)
 . I LA7AERR="",LA7SEQ<1 D REJECT("no MSH segment found") Q
 ;
 ;Now run processing routine
 ;D RECTIU
 ;
 ; Don't (ACK)nowledge ACK messages
 I $G(LA7MTYP)="ACK" Q
 ;
 ; HL7 returns this as ACK if no errors found
 I $G(LA7AERR)="" S HLA("HLA",1)="MSA"_LA7HLS("RFS")_"AA"_LA7HLS("RFS")_HL("MID")
 ;
 ; Send ACK message
 I $D(HLA("HLA")) D
 . S HLP("NAMESPACE")="LA"
 . S HLP("SUBSCRIBER")="^"_LA7RAP_"^"_LA7RSITE
 . D GENACK^HLMA1(HL("EID"),HLMTIENS,HL("EIDS"),"LM",1,.LA7HLSA,"",.HLP)
 ;
 Q
 ;
MSH ;MSH
 ;
 N LA7CFIG,LA7MID,LA7NOW,X
 ;
 S LA7SEQ=1
 S LA7FS=$E(LA7SEG(0),4)
 S LA7ECH=$E(LA7SEG(0),5,8)
 S LA7CS=$E(LA7ECH,1)
 ; Sending application
 S LA7SAP=$P($$P^LA7VHLU(.LA7SEG,3,LA7FS),LA7CS)
 ; Sending facility
 S LA7SSITE=$P($$P^LA7VHLU(.LA7SEG,4,LA7FS),LA7CS)
 ; Receiving application
 S LA7RAP=$P($$P^LA7VHLU(.LA7SEG,5,LA7FS),LA7CS)
 ; Receiving facility
 S LA7RSITE=$P($$P^LA7VHLU(.LA7SEG,6,LA7FS),LA7CS)
 ; Date/time of message
 S LA7MEDT=$$P^LA7VHLU(.LA7SEG,7,LA7FS)
 ; Message type/trigger event/message structure
 S X=$$P^LA7VHLU(.LA7SEG,9,LA7FS)
 S LA7MTYP=$P(X,LA7CS),LA7MTYP("EVN")=$P(X,LA7CS,2),LA7MTYP("MSGSTR")=$P(X,LA7CS,3)
 ; Message Control ID
 S LA7MID=$$P^LA7VHLU(.LA7SEG,10,LA7FS)
 ; Processing ID
 S LA7PRID=$$P^LA7VHLU(.LA7SEG,11,LA7FS)
 ; Version ID
 S LA7VER=$$P^LA7VHLU(.LA7SEG,12,LA7FS)
 ; Accept acknowledgement type
 S LA7AAT(0)=$$P^LA7VHLU(.LA7SEG,15,LA7FS)
 ; Application acknowledgement type
 S LA7AAT(1)=$$P^LA7VHLU(.LA7SEG,16,LA7FS)
 ;
 S LA7CFIG=LA7SAP_LA7SSITE_LA7RAP_LA7RSITE
 S X=LA7CFIG X ^%ZOSF("LPC")
 S LA76248=+$O(^LAHM(62.48,"C",$E(LA7CFIG,1,27)_Y,0))
 I 'LA76248 S LA76248=+$O(^LAHM(62.48,"B",LA7SAP,0))
 I 'LA76248,$E(LA7SAP,1,11)="LA7V REMOTE" S LA76248=+$O(^LAHM(62.48,"B","LA7V COLLECTION "_$P(LA7SAP," ",3),0))
 I 'LA76248 D  Q
 . S LA7ERR=1,LA7AERR=$$CREATE^LA7LOG(LA7ERR,1)
 . D REJECT("no config in 62.48")
 ;
 S LA76248(0)=$G(^LAHM(62.48,LA76248,0))
 ;
 ; Determine interface type
 S LA7INTYP=+$P(^LAHM(62.48,LA76248,0),"^",9)
 ;
 I '$P($G(^LAHM(62.48,LA76248,0)),"^",3) D
 . S LA7ERR=3,LA7AERR=$$CREATE^LA7LOG(LA7ERR,1)
 . D REJECT("config is inactive")
 ;
 ; store incoming message in ^LAHM(62.49)
 S LA76249=$$INIT6249^LA7VHLU
 I LA76249<1 Q
 ;
 ; update entry in 62.49
 N FDA,LA7FERR
 I $G(LA76248) S FDA(1,62.49,LA76249_",",.5)=LA76248
 S FDA(1,62.49,LA76249_",",1)="I"
 I LA7ERR S FDA(1,62.49,LA76249_",",2)="E"
 S FDA(1,62.49,LA76249_",",3)=3
 S FDA(1,62.49,LA76249_",",102)=LA7SAP
 S FDA(1,62.49,LA76249_",",103)=LA7SSITE
 S FDA(1,62.49,LA76249_",",104)=LA7RAP
 S FDA(1,62.49,LA76249_",",105)=LA7RSITE
 S FDA(1,62.49,LA76249_",",106)=LA7MEDT
 S FDA(1,62.49,LA76249_",",108)=LA7MTYP
 S FDA(1,62.49,LA76249_",",109)=LA7MID
 S FDA(1,62.49,LA76249_",",110)=LA7PRID
 S FDA(1,62.49,LA76249_",",111)=LA7VER
 S FDA(1,62.49,LA76249_",",700)=HL("EID")_";"_HLMTIENS_";"_HL("EIDS")
 D FILE^DIE("","FDA(1)","LA7FERR(1)")
 ;
 Q
 ;
 ;
REJECT(LA7AR) ;
 ; Setting HLA("HLA",1) conforms to HL7 package rules for acknowledgements
 ; LA7AR is a free text string that is included in the reject
 ; message for debugging purposes.
 ;
 S HLA("HLA",1)="MSA"_LA7HLS("RFS")_"AR"_LA7HLS("RFS")_HL("MID")_LA7HLS("RFS")_LA7AR
 S LA7AERR=LA7AR
 Q
 ;
EOR ;End of Routine SAMIVHL
