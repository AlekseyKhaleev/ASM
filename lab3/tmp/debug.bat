@echo off
echo Compiling...
..\tasm\tasm lab3.asm
if errorlevel 1 goto buildFail

echo Linking...
..\tasm\tlink lab3.obj
if errorlevel 1 goto linkingFail

echo Debugging...
..\tasm\td lab3.exe
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