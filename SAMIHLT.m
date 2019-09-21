SAMIHLT ;SAMI/lgc - HL7 TIU processing for VAPALS ;Sep 19, 2019@19:35
deprecated.  see SAMIVHL



 ;;
 ;;
 quit ; no entry from top
 ;
 ;@ppi
TIUREC ; Parse TIU into patients for patient-info graph
 D BLDMARR
 quit
 ;
RTNACK ; Return com ACK
quit
 ;
BLDMARR ; Build message array
 new SAMIMSG
 F LA7VI=1:1 X HLNEXT Q:HLQUIT'>0  D
 . K LA7SEG,LA7STYP
 . I HLNODE="" Q
 . S LA7SEG(0)=HLNODE
 . S LA7STYP=$E(LA7SEG(0),1,3)
 . S LA7VJ=0
 . F  S LA7VJ=$O(HLNODE(LA7VJ)) Q:'LA7VJ  D
 ..  S LA7SEG(LA7VJ)=HLNODE(LA7VJ)
 . M SAMIMSG(LA7STYP)=LA7SEG
 new cnt
 set cnt=$get(^KBAPMSG(0))+1
 merge ^KBAPMSG(cnt)=SAMIMSG
 quit
 ;
 ; Remember GENERATE^HTML
 ;
EOR ;End of Routine SAMIHLT
