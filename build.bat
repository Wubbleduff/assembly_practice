@echo off

set EXE=assembly.exe
set TEST_EXE=test.exe
set LIBS=User32.lib gdi32.lib shell32.lib kernel32.lib
set INTERMEDIATE=build_intermediate
set TEST_INTERMEDIATE=test_build_intermediate


mkdir %INTERMEDIATE%
mkdir %TEST_INTERMEDIATE%


pushd .

cd %INTERMEDIATE%

ml64 ..\assembly.asm /W3 /WX /Zi /Fo assembly.obj /c
if %errorlevel% neq 0 GOTO end_script

cl ..\main.c /std:c17 /W3 /WX /Zi /Fomain.obj /c
if %errorlevel% neq 0 GOTO end_script

link /subsystem:windows /DEBUG:FULL /OUT:"%EXE%" %LIBS% *.obj
if %errorlevel% neq 0 GOTO end_script

xcopy /Y %EXE% ..

popd



pushd . 

cd %TEST_INTERMEDIATE%

cl ..\test.c /std:c17 /W3 /WX /Zi /Fomain.obj /c
if %errorlevel% neq 0 GOTO end_script

link /subsystem:windows /DEBUG:FULL /OUT:"%TEST_EXE%" %LIBS% *.obj
if %errorlevel% neq 0 GOTO end_script

xcopy /Y %TEST_EXE% ..


:end_script
popd
exit /b %errorlevel%





