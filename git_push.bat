@echo off
echo ===================================================
echo  UPLOADING SMARTGO AI APP TO GITHUB
echo ===================================================
echo.

:: Check if git command exists
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed or not in your system PATH.
    echo Please install Git from https://git-scm.com/ and try again.
    echo.
    pause
    exit /b
)

:: Initialize Git if not initialized
if not exist .git (
    echo [1/5] Initializing Git repository...
    git init
) else (
    echo [1/5] Git repository already initialized.
)

:: Configure default branch name as main
git config --global init.defaultBranch main

:: Add/Update remote origin
echo [2/5] Setting up Git remote...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/Prash1775/smartigoai.git

:: Add files
echo [3/5] Adding files to Git stage...
git add .

:: Commit
echo [4/5] Creating commit...
git commit -m "Upload SmartGo AI codebase to main branch"

:: Rename current branch to main to be 100%% sure
git branch -M main

:: Push
echo [5/5] Pushing to GitHub (main branch)...
echo.
echo If a browser window or login prompt pops up, please authorize/log in.
echo.
git push -u origin main

echo.
echo ===================================================
echo  FINISHED!
echo ===================================================
pause
