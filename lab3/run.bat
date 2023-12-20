@echo off
echo Compiling...
::..\tasm\tasm data.asm build\obj build\lst\data.lst
::..\tasm\tasm macros.asm build\obj build\lst\macros.lst
..\tasm\tasm func.asm build\obj build\lst\func.lst
..\tasm\tasm main.asm build\obj build\lst\main.lst
if errorlevel 1 goto buildFail

echo Linking...
..\tasm\tlink /3 build\obj\main.obj build\obj\func.obj
if errorlevel 1 goto linkingFail

::echo Running...
::build/lab3.exe
::if errorlevel 1 goto runFail
::echo Success!
goto end

:buildFail
echo Build failed.
goto end

:linkingFail
echo Linking failed.
goto end

:runFail
echo Program encountered an error.
goto end

:end