@echo off

set arg_1=%1
rem replace @ with ,
set arg_1=%arg_1:@=,%
set arg_2=%2
set arg_3=%3
set arg_4=%4

rem check if enough arguments
if "%arg_4%"=="" (
	goto NO_ARGUMENT_DEFINED
)

set curpath="%~dp0"
set war_filename=%arg_1%
set root_dir=%arg_2%
set deploy_source_dir=%arg_3%
set service_name=%arg_4%

set webapp_folder=%root_dir%\webapps
set temp_folder=%root_dir%\work

rem if path does not exist then exit
if not exist %root_dir% goto WEB_PATH_NOT_FOUND

rem to generate date_time
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set date_time=%mydate%_%mytime%

rem stop service
echo.
echo Stopping services...
net stop %service_name%

rem create backup dir based on timestamp
echo.
echo Creating backup directory (%date_time%)...
set bk_dir=%root_dir%\bk\%date_time%
mkdir %bk_dir%

rem remove temporary files
echo.
echo Removing temporary files...
echo Removing %temp_folder%\Catalina\localhost...
cd %temp_folder%
del /S /Q *
rmdir /S /Q Catalina\localhost

rem change path to Tiget folder
rem backup existing war files
echo.
echo Backup WAR files into backup directory...
cd %webapp_folder%
for %%i in (%war_filename%) do (
	echo Moving %%i.war to %bk_dir%\%%i.war...
	move "%%i.war" "%bk_dir%\%%i.war"
	rmdir /S /Q %%i
)

rem deploy war files
echo.
echo Deploying WAR files...
rem if path does not exist then exit
if not exist %deploy_source_dir% goto DEPLOY_FOLDER_NOT_FOUND
for %%i in (%war_filename%) do (
	echo Copying %deploy_source_dir%\%%i.war to %webapp_folder%\%%i.war...
	copy "%deploy_source_dir%\%%i.war" "%webapp_folder%\%%i.war"
)

rem start service
echo.
echo Starting services...
net start %service_name%

rem script ends
echo.
echo Done.
cd %curpath%
goto EXIT

:WEB_PATH_NOT_FOUND
echo.
echo Web container path not found. 
goto EXIT

:DEPLOY_FOLDER_NOT_FOUND
echo.
echo Directory to WAR files not found.
goto EXIT

:NO_ARGUMENT_DEFINED
rem arguments are not defined
echo.
echo Please note that this script works for Tomcat only. 
echo Please define all arguments.
echo arg_1: Filename. e.g. DOMAIN@DAEMON (Multiple values possible, delimited by @)
echo arg_2: Path to web container folder. e.g. C:\Tiger\apache-tomee-webprofile-1.7.4
echo arg_3: Path to new WAR files to be deployed
echo arg_4: Service name to stop and restart after deployment.
echo.

:EXIT
