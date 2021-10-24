@echo off

goto :start

:get_locale 
  FOR /F "tokens=3 usebackq delims= " %%o IN (`reg query "HKCU\Control Panel\International" /v LocaleName`) do (set locale=%%o)
  exit /b

:get_arg
  if [%1]==[] goto :missing_arg
  set arg=%1
  exit /b

:missing_arg
  echo Failure: missing argument: %arg%
  exit /b 1

:get_arg_command
  set arg=COMMAND
  call :get_arg %1 || exit /b 1
  set cmd=%arg%
  exit /b

:get_arg_printer
  set arg=PRINTER
  call :get_arg %1 || exit /b 1
  set printer=%arg%
  exit /b

:get_arg_port
  set arg=PORT
  call :get_arg %1 || exit /b 1
  set port=%arg% 
  exit /b
  
:get_arg_job
  set arg=JOB
  call :get_arg %1 || exit /b 1
  set job=%arg%
  exit /b

:get_arg_ip
  set arg=IP
  call :get_arg %1 || exit /b 1
  set ip=%arg%
  exit /b
  
:list_printers
  rem output all printer names
  if %verbose%==1 goto :list_printers_verbose
  for /F "tokens=3,* usebackq" %%G in (`%run_script%\prnmngr.vbs -l ^| find "Printer name"`) do (echo %%G %%H)
  exit /b

:list_printers_verbose
  rem output all data for all printers
  %run_script%\prnmngr.vbs -l 
  exit /b

:list_ports
  if %verbose%==1 goto :list_ports_verbose
  for /F "tokens=3,* usebackq" %%G in (`%run_script%\prnport.vbs -l ^| find "Port name"`) do (echo %%G %%H)
  exit /b

:list_ports_verbose
  %run_script%\prnport.vbs -l
  exit /b

:show_printer
  call :get_arg_printer %1 || goto :usage
  echo printer=%printer%
  %run_script%\prncnfg.vbs -g -p %printer%
  exit /b

:show_port
  call :get_arg_port %1 || goto :usage
  %run_script%\prnport.vbs -g -r %port%
  exit /b

:add_port
  call :get_arg_port %1 || goto :usage
  shift
  call :get_arg_ip %1 || goto :usage
  %run_script%\prnport.vbs -a -r %port% -h %ip% 
  exit /b

:delete_port
  call :get_arg_port %1 || goto :usage
  %run_script%\prnport.vbs -d -r %port%
  exit /b

:get_printer_port
  call :get_arg_printer %1 || goto :usage
  for /F "tokens=3,* usebackq" %%G in (`%run_script%\prncnfg.vbs -g -p "%printer%" ^| find "Port name"`) do (echo %%G %%H)
  exit /b

:set_printer_port
  call :get_arg_printer %1 || goto :usage
  shift
  call :get_arg_port %1 || goto :usage
  %run_script%\prncnfg.vbs -t -p %printer% -r %port%
  exit /b

:get_default
  %run_script%\prnmngr.vbs -g
  exit /b
 
:set_default
  call :get_arg_printer %1 || goto :usage
  %run_script%\prnmngr.vbs -t -p %printer%
  exit /b

:print_test_page
  call :get_arg_printer %1 || goto :usage
  %run_script%\prnqctl.vbs -e -p %printer%
  exit /b

:queue_pause
  call :get_arg_printer %1 || goto :usage 
  %run_script%\prnqctl.vbs -z -p %printer%
  exit /b

:queue_resume
  call :get_arg_printer %1 || goto :usage 
  %run_script%\prnqctl.vbs -m -p %printer%
  exit /b

:queue_purge
  call :get_arg_printer %1 || goto :usage 
  %run_script%\prnqctl.vbs -x -p %printer%
  exit /b

:queue_list_jobs
  call :get_arg_printer %1 || goto :usage
  %run_script%\prnjobs.vbs -l -p %printer%
  exit /b

:queue_cancel_job
  call :get_arg_printer %1 || goto :usage 
  shift
  call :get_arg_job %1 || goto :usage
  %run_script%\prnjobs.vbs -x -p %printer% -j %job%
  exit /b

:queue_pause_job
  call :get_arg_printer %1 || goto :usage 
  shift
  call :get_arg_job %1 || goto :usage
  %run_script%\prnjobs.vbs -z -p %printer% -j %job%
  exit /b

:set_verbose
  set verbose=1
  shift
  exit /b

:start
call :get_locale
set verbose=0
if [%1]==[--verbose] set verbose=1 & shift
if [%1]==[-v] set verbose=1 & shift
call :get_arg_command %1 || goto :usage
shift
set scripts=%WINDIR%\System32\printing_Admin_Scripts\%locale%
set run_script=cscript //Nologo %scripts%
if [%cmd%]==[printers] goto :list_printers
if [%cmd%]==[ports] goto :list_ports
if [%cmd%]==[show-printer] goto :show_printer 
if [%cmd%]==[show-port] goto :show_port
if [%cmd%]==[get-default] goto :get_default
if [%cmd%]==[set-default] goto :set_default
if [%cmd%]==[get-port] goto :get_printer_port
if [%cmd%]==[set-port] goto :set_printer_port
if [%cmd%]==[add-port] goto :add_port
if [%cmd%]==[delete-port] goto :delete_port
if [%cmd%]==[test-page] goto :print_test_page
if [%cmd%]==[queue-pause] goto :queue_pause
if [%cmd%]==[queue-resume] goto :queue_resume
if [%cmd%]==[queue-purge] goto :queue_purge
if [%cmd%]==[queue-list] goto :queue_list_jobs
if [%cmd%]==[queue-pause] goto :queue_pause_job
if [%cmd%]==[queue-cancel] goto :queue_cancel_job

:usage
echo Usage:
echo   [--verbose] printers ------ list printers
echo   [--verbose] ports --------- list TCP/IP printer ports
echo   show-printer PRINTER ------ show printer configuration
echo   show-port PORT ------------ show PORT configuration
echo   get-default --------------- show default printer
echo   set-default PRINTER ------- set PRINTER as default
echo   get-port PRINTER ---------- show PRINTER port
echo   set-port PRINTER PORT ----- set PRINTER to use PORT
echo   add-port PORT IP ---------- add TCP/IP printer PORT for IP
echo   delete-port PORT ---------- delete TCP/IP printer PORT
echo   test-page PRINTER --------- request test page on PRINTER
echo   queue-pause PRINTER ------- pause PRINTER queue
echo   queue-resume PRINTER ------ resume PRINTER queue
echo   queue-purge PRINTER ------- delete all jobs from PRINTER queue
echo   queue-list PRINTER -------- list jobs in PRINTER queue
echo   queue-pause PRINTER JOB --- pause PRINTER queue JOB
echo   queue-cancel PRINTER JOB -- cancel PRINTER queue JOB
exit /b

