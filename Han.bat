@echo off
title=BDO汉化

if not exist %TEMP%\BDOHan\ (
	mkdir %TEMP%\BDOHan\
)

echo 读取游戏目录
call :readini config.ini BDO GamePath GAMEPATH
if not defined %GAMEPATH (
	echo 读取配置文件失败
	call :exit
)
if not exist %GAMEPATH%\ads\ (
	echo 错误的游戏目录
	call :exit
)
echo 游戏目录为：%GAMEPATH%

echo 读取代理设置
call :readini config.ini PROXY Enable PROXY_ENABLE
call :readini config.ini PROXY Address PROXY_ADDRESS
if not defined %PROXY_ENABLE (
	echo 读取配置文件失败
	call :exit
)
if "%PROXY_ENABLE%" NEQ "0" if "%PROXY_ENABLE%" NEQ "1" (
	echo 错误的代理选项
	call :exit
)
if "%PROXY_ENABLE%" EQU "1" (
	if not defined %PROXY_ADDRESS (
		echo 读取配置文件失败
		call :exit
	)
	echo 代理服务地址为：%PROXY_ADDRESS%
)
if "%PROXY_ENABLE%" EQU "0" (
	echo 设置为不使用代理
)

echo 获取语言文件版本号
if "%PROXY_ENABLE%" EQU "0" (
	for /F %%i in ('curl -L https://dn.blackdesert.com.tw/UploadData/ads_version --silent --fail --show-error') do (set version=%%i)
)
if "%PROXY_ENABLE%" EQU "1" (
	for /F %%i in ('curl -L https://dn.blackdesert.com.tw/UploadData/ads_version -x %PROXY_ADDRESS% --silent --fail --show-error') do (set version=%%i)
)
if not defined %version (
	echo 获取版本号失败
	call :exit
)
echo 语言文件版本号为：%version%

echo 下载语言文件
if "%PROXY_ENABLE%" EQU "0" (
	curl -L https://dn.blackdesert.com.tw/UploadData/ads/languagedata_tw/%version%/languagedata_tw.loc --silent --fail --show-error --output %TEMP%\BDOHan\languagedata_tw.loc
)
if "%PROXY_ENABLE%" EQU "1" (
	curl -L https://dn.blackdesert.com.tw/UploadData/ads/languagedata_tw/%version%/languagedata_tw.loc -x %PROXY_ADDRESS% --silent --fail --show-error --output %TEMP%\BDOHan\languagedata_tw.loc
)
if "%errorlevel%" NEQ "0" (
	echo 下载失败
	call :exit
)
echo 下载完成

echo 开始解码语言文件
bin\BDO_decrypt %GAMEPATH%\ads\languagedata_en.loc %TEMP%\BDOHan\languagedata_en.txt
bin\BDO_decrypt %TEMP%\BDOHan\languagedata_tw.loc %TEMP%\BDOHan\languagedata_tw.txt
echo 解码完成

echo 开始混合语言文件
bin\ReplaceLanguage %TEMP%\BDOHan\languagedata_tw.txt %TEMP%\BDOHan\languagedata_en.txt %TEMP%\BDOHan\mixed.txt
echo 混合完成

echo 开始汉化游戏
bin\BDO_encrypt %TEMP%\BDOHan\mixed.txt %GAMEPATH%\ads\languagedata_tw.loc
echo 汉化完成

call :exit

:readini
setlocal EnableExtensions EnableDelayedExpansion

set file=%~1
set area=[%~2]
set key=%~3
set currarea=

for /f "usebackq delims=" %%a in ("!file!") do (
	set ln=%%a
	if "x!ln:~0,1!" == "x[" (
		set currarea=!ln!
	) else (
		for /f "tokens=1,2 delims==" %%b in ("!ln!") do (
			set currkey=%%b
			set currval=%%c
			if "x!area!" == "x!currarea!" (
				if "x!key!" == "x!currkey!" (
					set var=!currval!
				)
			)
		)
	)
)
(endlocal
	set %~4=%var%
)
goto :eof

:exit
rmdir /S/Q %TEMP%\BDOHan\
pause
exit
goto :eof