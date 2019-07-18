KBAPPP ;ven/lgc - PULL PATCHES FROM OSEHRA - ; 6/14/19 8:57pm
 ;;
 ;
 ; Routine to run on our patch server which pulls all the
 ;  patches from the OSEHRA web server and saves them
 ;  in the ~/patch/ directory on our server
 ; Another routine, KBAPCKSM, on the client, allows pulling
 ;  patches for KIDS install on the client.
 ;
 quit  ; no entry from top
 ;
 ;@ppi
GETMURL ;
 ;@input
 ;  none
 ;@output
 ;  creates-files saves each file gleaned from the url
 ;                onto our web server
 new months,month,monthy,year
 new url,newurl,filename,cmd,cnt,RTN
 ;
 set months="January,February,March,April,May,June,July,August,September,October,November,December" do
 ;
 set url="https://foia-vista.osehra.org/Patches%20by%20Year%20and%20Month%20Released/"
 ;
 ; Gather all patches under the 2011 through 2019 directories
 ;  and within that the month directory
 for year=2011:1:2019 write !,year do
 . for cnt=1:1:12 set month=$piece(months,",",cnt) do
 ..; month directories are all upper case for 2011 and 2012
 ..;  and camel case for subsequent years.
 .. if year<2013 set month=$$UP^XLFSTR(month)
 .. set monthy=month_"%2020"_$extract(year,3,4)
 ..; set newurl to the year/month directory on the OSEHRA server
 .. set newurl=url_year_"/"_monthy_"/"
 ..;
 ..; save HTML file with all the patches for the specified
 ..;   year and month directory on the OSEHRA server
 ..;   e.g. Patches-2015-JANUARY
 ..;
 .. set filename="Patches-"_year_"-"_month
 .. set cmd="curl -o "_"~/patch/"_filename_" "_newurl
 .. write !,cmd,!
 .. zsystem cmd
 ..;
 ..; now parse out all the patch files in this file of HTML
 ..;  code and save each patch file onto our server under the
 ..;  ~/patch/ directory
 ..;
 .. do SAVEPTCH(filename,newurl)
 ;
 ; For ease of pulling the names of all the files on our
 ;  patch server onto a client, build a file that lists
 ;  the directory of ~/patch/
 ;
 ; Build file with names of all patches in directory
 do ALLPTCHS^KBAPPP
 ;
 ; And before we leave we will rebuild symbol table
 set cmd="do build^%yottagr"
 zsystem cmd
 ;
 quit
 ;
 ;
 ;
 ;Parse out all the patch file names from this file 
 ;  containing the HTML for the contents of one of the
 ;  month-year patch directories from the OSEHRA web site
 ;@ppi
SAVEPTCH(filename,newurl) ; Parse out HTML in year-month file
 ;@input
 ;   filename  = name of the file containing the HTML for
 ;               a month-year of patches
 ;               e.g. Patches-2014-May
 ;   newurl    = url where patches may be found
 ;               e.g. https://foia-vista.osehra.org/Patches%20by%20Year%20and%20Month%20Released/2014/May%202014/
 ;@output
 ;   creates-file saves file on client
 quit:($get(filename)="")
 quit:($get(newurl)="")
 ;
 new line,cnt,RTN,ptchname
 ;
 ; open the requested file that had been downloaded from
 ;   the OSEHRA site (e.g. Patches-2014-May)
 do OPEN^%ZISH("FILE","/home/osehra/patch/",filename,"R")
 quit:POP
 ;
 ; Read the HTML from the file into an array RTN
 for  use IO read line:1 quit:$$STATUS^%ZISH  do
 . set RTN=$G(RTN)+1,RTN(RTN)=line
 do CLOSE^%ZISH
 ;
 ; Now march through the array of HTML lines, parse
 ;   out patch file names.  Use these names to build
 ;   the url to the OSEHRA server to download a patch
 ;   file onto our patch server
 set cnt=0
 for  set cnt=$order(RTN(cnt)) quit:'cnt  do
 . set ptchname=$P($P($tr(RTN(cnt),""""),"href=",2),"><")
 . quit:ptchname=""
 . quit:ptchname[":"
 . quit:ptchname["%"
 . quit:ptchname["<"
 . quit:ptchname[">"
 . write !,$length(ptchname)," ",ptchname
 .;
 . set ptchurl=newurl_ptchname
 .; 
 .; use curl to save the patch off the OSEHRA server onto
 .;  our patch server
 . set cmd="curl -o "_"~/patch/"_ptchname_" "_ptchurl
 . write !,cmd,!
 . zsystem cmd
 quit
 ;
 ;
 ; Save the directory of patch files on our patch server
 ;  into a file AllPatches.txt.  This may be used by
 ;  clients to simplify obtaining a list of all patch files
 ;  on our server
ALLPTCHS ;
 new cmd,dir
 set cmd="""cd ~/patch"""
 zsystem @cmd
 ;
 set dir="/home/osehra/patch/"
 set cmd="""ls "_dir_" > /home/osehra/patch/AllPatches.txt"""
 zsystem @cmd
 quit
 ;
EOF ;End of routine KBAPPP
