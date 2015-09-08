@echo off

REM Enable exapnsion for inner FOR loops
REM and initialize check variable for logical operations
setlocal enabledelayedexpansion
set check=1

REM Overwrite file if already exists
echo > output.txt

REM Some additional formatting and date and time
echo. >> output.txt
echo. >> output.txt
echo %date% >> output.txt
echo %time% >> output.txt
echo. >> output.txt
echo. >> output.txt

REM Header or Title for columns of CSV
echo IP Address ; ICMP Test ; SNMP Test >> output.txt

REM Loop through IP addresses or FQDNs in list.txt file
for /F "delims=; tokens=1" %%a in (list.txt) DO (

    set ipaddr=%%a
    set icmp=0

    for /F "delims==, tokens=4" %%c IN ('ping -n 2 !ipaddr! ^| findstr /R "^Packets: Sent =.$"') DO (

        if %%c EQU 2 (
            set icmp=OK
            set /a check=!check!*1
        ) ELSE (
            if %%c EQU 1 (
            set icmp=OK
            set /a check=!check!*1
        )   ELSE (
                set icmp=Not OK
                set /a check=!check!*0
            )
        )

    REM for loop ICMP
    )

    set snmp=0

    FOR /F "delims== tokens=4" %%l IN ('SnmpWalk.exe -r:!ipaddr! -v:<snmp-version> -c:<snmp-comm-string> -os:1.3.6.1.2.1.2.1 -op:1.3.6.1.2.1.2.2') DO (

        if %%l GTR 0 (
            set snmp=OK
        )
    
    REM for loop SNMP
    )

    if !snmp! EQU 0 set snmp=Not OK

    echo !ipaddr! ; !icmp! ; !snmp! >> output.txt

REM for loop list.txt
)



if %check% EQU 0 (
    echo. >> output.txt
    echo. >> output.txt
    echo. >> output.txt
    echo. >> output.txt
    echo ^------------------------------------------------- >> output.txt
    echo ^---------------- Detailed Output ---------------- >> output.txt
    echo ^------------------------------------------------- >> output.txt
    echo. >> output.txt
    echo. >> output.txt

    for /F "delims=; tokens=1" %%a in (list.txt) DO (
        set ipaddr=%%a
        tracert -d -h 10 -w 1000 !ipaddr!
    ) >> output.txt
)
