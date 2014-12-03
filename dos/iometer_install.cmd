@echo off

set tmp=C:\ftp.txt
set iometer_dir=C:\iometer
rmdir /s /q %iometer_dir%
mkdir %iometer_dir%
echo open 200.200.0.3>>%tmp%
echo test>>%tmp%
echo test>>%tmp%
echo cd /VS/tools/iometer>>%tmp%
echo lcd %iometer_dir%>>%tmp%
echo get Dynamo.exe>>%tmp%
echo get Iometer.exe>>%tmp%
echo quit>>%tmp%
ftp -i -s:%tmp%
del -f %tmp%

cd %iometer_dir%
start %iometer_dir%\Iometer.exe
exit