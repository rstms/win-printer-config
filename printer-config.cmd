@echo off

goto :start

:get_locale
  FOR /F "tokens=* usebackq" %%o IN (`dism /Online /get-intl ^| find "System locale"`) do (set result=%%o)
  FOR /F "tokens=3 usebackq delims=: " %%o IN (`echo %result%`) do (set $locale=%%o)
  exit /b

:list_printers_old
  set $ls_printers=%TMP%\list_printers.vbs
  echo>%$ls_printers% Set WshNetwork = WScript.CreateObject("WScript.Network")
  echo>>%$ls_printers% Set oPrinters = WshNetwork.EnumPrinterConnections
  echo>>%$ls_printers% Wscript.Echo "Printer : Port"
  echo>>%$ls_printers% For i = 0 to oPrinters.Count - 1 Step 2
  echo>>%$ls_printers%   Wscript.Echo "'" ^& oPrinters.Item(i+1) ^& "' : '" ^& oPrinters.Item(i) ^& "'"
  echo>>%$ls_printers% Next
  cscript %$ls_printers%
  del %$ls_printers%
  exit /b

:list_printers

:start
call :get_locale
set $script=%WINDIR%\System32\printing_Admin_Scripts\%$locale%\prnport.vbs
echo locale=%$locale%
echo script=%$script%
cscript %$script% %1 %2 %3
call :list_printers

:end
exit /b
