REM #!/bin/sh 
echo off

SET DEMO=JBoss Fuse Websocket Demo
SET VERSION=6.0.0
REM The following two lines will need to be updated if the version of jboss-fuse
REM is later than -024.
SET FUSE=jboss-fuse-full-6.0.0.redhat-024
SET FUSE_BIN=jboss-fuse-full-6.0.0.redhat-024.zip
SET DEMO_HOME=.\target
SET FUSE_HOME=%DEMO_HOME%\%FUSE%
SET SERVER_CONF=%FUSE_HOME%\etc
SET SRC_DIR=.\installs
SET PRJ_DIR=.\projects\jboss-fuse-websocket-demo

echo " "
echo Setting up the Red Hat %DEMO% environment...
echo " "

REM double check for maven.
REM command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }
call mvn --version
if %errorlevel% NEQ 0 (
	echo "Maven is required but not installed yet... aborting." 
	pause
	exit /b
) else (
	echo "Maven is installed"
)


REM make some checks first before proceeding.	
if exist %SRC_DIR%/%FUSE_BIN% (
		echo %DEMO% sources are present...
		echo " "
) else (
		echo Need to download %FUSE_BIN% package from the Customer Support Portal 
		echo and place it in the %SRC_DIR% directory to proceed...
		echo " "
		pause

		exit /b
)


REM Create the target directory if it does not already exist.
if not exist %DEMO_HOME%  (
		echo "  - creating the demo home directory..."
		echo " "
		md %DEMO_HOME%
) else (
		echo "  - detected demo home directory %DEMO_HOME%, moving on..."
		echo " "
)


REM Move the old JBoss instance, if it exists, to the OLD position.
if exist %FUSE_HOME% (
		echo "  - existing JBoss Fuse detected %FUSE_HOME%..."
		echo " "
		echo "  - moving existing JBoss Fuse aside..."
		echo " "

		if exist %FUSE_HOME%.OLD (
			echo "deleting..."
			echo %FUSE_HOME%.OLD
			del /F /S /Q %FUSE_HOME%.OLD
		) else (
			echo creating %FUSE_HOME%.OLD...
			md %FUSE_HOME%.OLD 
		)
		echo moving %FUSE_HOME% %FUSE_HOME%.OLD ...
		move /Y %FUSE_HOME% %FUSE_HOME%.OLD
		echo done

		REM Unzip the JBoss instance.
		echo Unpacking JBoss Fuse %VERSION%
		echo " "
		unzip -o -v -d %DEMO_HOME% %SRC_DIR%/%FUSE_BIN%
) else (
		REM Unzip the JBoss instance.
		echo Unpacking new JBoss Fuse...
		echo " "
		unzip -o -v -d %DEMO_HOME% %SRC_DIR%/%FUSE_BIN%
)

if not exist %SERVER_CONF% md %SERVER_CONF%

echo "  - enabling demo accounts logins in users.properties file..."
echo " "
copy support\users.properties %SERVER_CONF%

echo "  - copying updated JBoss A-MQ configuration file fuseamq-websocket.xml from project..."
echo " "
copy %PRJ_DIR%\feeder\src\main\config\fuseamq-websocket.xml %SERVER_CONF%\activemq.xml

echo "  - making sure 'fuse' for server is executable..."
echo " "
REM chmod u+x %FUSE_HOME%/bin/fuse

echo Now going to build the project.
echo " "
cd %PRJ_DIR%
mvn clean install -DskipTests

echo " "
echo To get started see the README.md file:
echo " "
cd ../..
cat README.md

echo Red Hat %DEMO% %VERSION% Setup Completed.
echo " "
pause

