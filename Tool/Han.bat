@echo off
title=BDO����

if not exist %TEMP%\BDOHan\ (
	mkdir %TEMP%\BDOHan\
)

echo ��ȡ��ϷĿ¼
call :readini config.ini BDO GamePath GAMEPATH
if not defined %GAMEPATH (
	echo ��ȡ�����ļ�ʧ��
	call :exit
)
if not exist %GAMEPATH%\ads\ (
	echo �������ϷĿ¼
	call :exit
)
echo ��ϷĿ¼Ϊ��%GAMEPATH%

echo ��ȡ��������
call :readini config.ini PROXY Enable PROXY_ENABLE
call :readini config.ini PROXY Address PROXY_ADDRESS
if not defined %PROXY_ENABLE (
	echo ��ȡ�����ļ�ʧ��
	call :exit
)
if "%PROXY_ENABLE%" NEQ "0" if "%PROXY_ENABLE%" NEQ "1" (
	echo ����Ĵ���ѡ��
	call :exit
)
if "%PROXY_ENABLE%" EQU "1" (
	if not defined %PROXY_ADDRESS (
		echo ��ȡ�����ļ�ʧ��
		call :exit
	)
	echo ��������ַΪ��%PROXY_ADDRESS%
)
if "%PROXY_ENABLE%" EQU "0" (
	echo ����Ϊ��ʹ�ô���
)

echo ��ȡ�����ļ��汾��
if "%PROXY_ENABLE%" EQU "0" (
	for /F %%i in ('curl -L https://dn.blackdesert.com.tw/UploadData/ads_version --silent --fail --show-error') do (set version=%%i)
)
if "%PROXY_ENABLE%" EQU "1" (
	for /F %%i in ('curl -L https://dn.blackdesert.com.tw/UploadData/ads_version -x %PROXY_ADDRESS% --silent --fail --show-error') do (set version=%%i)
)
if not defined %version (
	echo ��ȡ�汾��ʧ��
	call :exit
)
echo �����ļ��汾��Ϊ��%version%

echo ���������ļ�
if "%PROXY_ENABLE%" EQU "0" (
	curl -L https://dn.blackdesert.com.tw/UploadData/ads/languagedata_tw/%version%/languagedata_tw.loc --silent --fail --show-error --output %TEMP%\BDOHan\languagedata_tw.loc
)
if "%PROXY_ENABLE%" EQU "1" (
	curl -L https://dn.blackdesert.com.tw/UploadData/ads/languagedata_tw/%version%/languagedata_tw.loc -x %PROXY_ADDRESS% --silent --fail --show-error --output %TEMP%\BDOHan\languagedata_tw.loc
)
if "%errorlevel%" NEQ "0" (
	echo ����ʧ��
	call :exit
)
echo �������

echo ��ʼ���������ļ�
bin\BDO_decrypt %GAMEPATH%\ads\languagedata_en.loc %TEMP%\BDOHan\languagedata_en.txt
bin\BDO_decrypt %TEMP%\BDOHan\languagedata_tw.loc %TEMP%\BDOHan\languagedata_tw.txt
echo �������

echo ��ʼ��������ļ�
bin\ReplaceLanguage %TEMP%\BDOHan\languagedata_tw.txt %TEMP%\BDOHan\languagedata_en.txt %TEMP%\BDOHan\mixed.txt
echo ������

echo ��ʼ������Ϸ
bin\BDO_encrypt %TEMP%\BDOHan\mixed.txt %GAMEPATH%\ads\languagedata_tw.loc
echo �������

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