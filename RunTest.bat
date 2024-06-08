@echo off
set batdir=%~dp0
cd /d "%batdir%"

pushd .\lua\testes

lua -W all.lua >nul

popd