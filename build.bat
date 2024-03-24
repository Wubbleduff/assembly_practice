@echo off

set EXE=assembly.exe
set LIBS=User32.lib gdi32.lib shell32.lib kernel32.lib
set INTERMEDIATE=build_intermediate

set ASSEMBLER_FLAGS=/W3 /WX /Zi /Fo%INTERMEDIATE%\ /c
set COMPILER_FLAGS=/std:c17 /W3 /WX /Zi /Fo%INTERMEDIATE%\ /c
set LINK_FLAGS=/subsystem:windows /DEBUG:FULL /OUT:"%INTERMEDIATE%\%EXE%"

mkdir %INTERMEDIATE%

ml64 assembly.asm %ASSEMBLER_FLAGS% 
if %errorlevel% neq 0 exit /b %errorlevel%

cl main.c %COMPILER_FLAGS%
if %errorlevel% neq 0 exit /b %errorlevel%

link %LINK_FLAGS% %LIBS% %INTERMEDIATE%\*.obj
if %errorlevel% neq 0 exit /b %errorlevel%

xcopy /Y %INTERMEDIATE%\%EXE% .

REM assembly.exe
REM echo %errorlevel%

