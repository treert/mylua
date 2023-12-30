@echo off
set batdir=%~dp0
cd /d "%batdir%"

pushd .\mylua\testes

lua -W all.lua >nul

popd