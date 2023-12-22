@echo off
@echo off
echo Compiling...
..\tasm\tasm main.asm build\ build\main.lst
if errorlevel 1 goto buildFail

echo Linking...
..\tasm\tlink /3 build\main.obj
if errorlevel 1 goto linkingFail

echo Debugging...
..\tasm\td build\main.exe
if errorlevel 1 goto runFail
echo Success!
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