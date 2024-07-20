@echo off
set batdir=%~dp0
cd /d "%batdir%"

set config=release
if "%1" == "debug" (
    echo build debug version
    set config=debug
)
@echo on
cmake --build build --target install --config %config%