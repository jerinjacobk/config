@echo off
REM === Load your DOSKEY macros ===
doskey /macrofile="C:\Users\jerin\config\windows\doskey_macros.cmd"

REM === Change to working directory ===
cd /d "C:\Users\jerin\jtrade"

REM === Activate your Python virtual environment ===
call ".venv\Scripts\activate"

REM === Optional: show where we are ===
echo Working directory: %CD%
