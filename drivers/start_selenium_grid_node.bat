@echo off
reg query "HKEY_CURRENT_USER\Software\Google\Chrome\BLBeacon" /v version>chrome_version.txt
set /a chrome_version=78
find /c "REG_SZ    79." chrome_version.txt>debug.txt  && ( set /a chrome_version=79 )
find /c "REG_SZ    80." chrome_version.txt>debug.txt  && ( set /a chrome_version=80 )
find /c "REG_SZ    81." chrome_version.txt>debug.txt  && ( set /a chrome_version=81 )
find /c "REG_SZ    83." chrome_version.txt>debug.txt  && ( set /a chrome_version=83 )
find /c "REG_SZ    84." chrome_version.txt>debug.txt  && ( set /a chrome_version=84 )
find /c "REG_SZ    85." chrome_version.txt>debug.txt  && ( set /a chrome_version=85 )
find /c "REG_SZ    86." chrome_version.txt>debug.txt  && ( set /a chrome_version=86 )
find /c "REG_SZ    87." chrome_version.txt>debug.txt  && ( set /a chrome_version=87 )
find /c "REG_SZ    88." chrome_version.txt>debug.txt  && ( set /a chrome_version=88 )
find /c "REG_SZ    89." chrome_version.txt>debug.txt  && ( set /a chrome_version=89 )
find /c "REG_SZ    90." chrome_version.txt>debug.txt  && ( set /a chrome_version=90 )
find /c "REG_SZ    91." chrome_version.txt>debug.txt  && ( set /a chrome_version=91 )
find /c "REG_SZ    92." chrome_version.txt>debug.txt  && ( set /a chrome_version=92 )

echo chrome_version=%chrome_version%
del chrome_version.txt
del debug.txt
java -Dwebdriver.chrome.driver="chromedriver_%chrome_version%.exe" -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-3.141.59.jar -role webdriver -nodeConfig grid_nodeconfig.json
