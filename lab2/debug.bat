@echo off
echo Compiling...
..\tasm\tasm lab2_com.asm
if errorlevel 1 goto buildFail

echo Linking...
..\tasm\tlink /l /t lab2_com.obj
if errorlevel 1 goto linkingFail

echo Debugging...
..\tasm\td lab2_com.com
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