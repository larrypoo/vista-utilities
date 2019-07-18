KBAPCKSM ;ven/lgc - Patch utilities ; 6/13/19 10:26am
 ;;;;
 quit  ; no entry from top
 ;
 ; e.g. ptchname="OOPS-2_SEQ-21_PAT-22.TXT",path="~/tmp/"
PULLPTCH(ptchname,path) ; Pull a patch from patch server
 n url,cmd,filename
 ; set url to patch server
 s url="http://patch.fiscientific.org:9080/filesys/sami/patch/"
 s url=url_ptchname
 s filename=path_ptchname
 s cmd="curl -o "_filename_" "_url
 zsystem cmd
 quit
 ;
EOF ;End of routine KBAPCKSM
