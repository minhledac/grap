@echo off
REM upgrade pip
python -m pip install --upgrade pip
REM Install robot librarys for Python
python -m pip install robotframework
python -m pip install robotframework-StringFormat
python -m pip install robotframework-jsonlibrary
python -m pip install robotframework-requests==0.4.7
python -m pip install robotframework-SeleniumLibrary
python -m pip install robotframework-pabot
python -m pip install robotframework-excellib
python -m pip install robotframework-archivelibrary
python -m pip install robotframework-metrics
python -m pip install pdfplumber
REM Install packages for Atom
apm install --packages-file atom-package-list.txt
REM Install google api to quick update common key words
install_node_modules.bat
echo ======================================================
echo Done!
pause
