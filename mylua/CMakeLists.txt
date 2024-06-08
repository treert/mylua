cmake_minimum_required(VERSION 3.6)

# mylua 单独编译用，和 lua 目录里的大致类似。

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)  # C++ 11 是强制要求，不会衰退至低版本
set(CMAKE_CXX_EXTENSIONS OFF)  # 禁止使用编译器特有扩展

set(MY_LUA_Root ${CMAKE_CURRENT_SOURCE_DIR})
set(LUA_SRC_PATH ${PROJECT_SOURCE_DIR}/lua)
set (LUA_SRC_FILES
    ${LUA_SRC_PATH}/lapi.c
    ${LUA_SRC_PATH}/lbaselib.c
    ${LUA_SRC_PATH}/lcorolib.c
    ${LUA_SRC_PATH}/ldblib.c
    ${LUA_SRC_PATH}/ldo.c
    ${LUA_SRC_PATH}/lfunc.c
    ${LUA_SRC_PATH}/linit.c
    ${LUA_SRC_PATH}/llex.c
    ${LUA_SRC_PATH}/lmem.c
    ${LUA_SRC_PATH}/lobject.c
    ${LUA_SRC_PATH}/loslib.c
    ${LUA_SRC_PATH}/lstate.c
    ${LUA_SRC_PATH}/lstrlib.c
    ${LUA_SRC_PATH}/ltablib.c
    ${LUA_SRC_PATH}/ltm.c
    ${LUA_SRC_PATH}/lutf8lib.c
    ${LUA_SRC_PATH}/lzio.c
    ${LUA_SRC_PATH}/lauxlib.c
    ${LUA_SRC_PATH}/lcode.c
    ${LUA_SRC_PATH}/lctype.c
    ${LUA_SRC_PATH}/ldebug.c
    ${LUA_SRC_PATH}/ldump.c
    ${LUA_SRC_PATH}/lgc.c
    ${LUA_SRC_PATH}/liolib.c
    ${LUA_SRC_PATH}/lmathlib.c
    ${LUA_SRC_PATH}/loadlib.c
    ${LUA_SRC_PATH}/lopcodes.c
    ${LUA_SRC_PATH}/lparser.c
    ${LUA_SRC_PATH}/lstring.c
    ${LUA_SRC_PATH}/ltable.c
    ${LUA_SRC_PATH}/ltests.c
    ${LUA_SRC_PATH}/lundump.c
    ${LUA_SRC_PATH}/lvm.c
)

add_library ( liblua_share SHARED ${LUA_SRC_FILES})
target_compile_definitions ( liblua_share PRIVATE LUA_BUILD_AS_DLL)
# target_compile_definitions ( liblua_share PRIVATE _CRT_SECURE_NO_WARNINGS) # 屏蔽 scranf() 不安全的警告
target_compile_definitions ( liblua_share PRIVATE LUAI_MAXCCALLS=128) # windows 上 cstack.lua 溢出报错
target_include_directories(liblua_share PUBLIC ${LUA_SRC_PATH})
set_target_properties ( liblua_share PROPERTIES OUTPUT_NAME mylua )

add_executable ( lua ${LUA_SRC_PATH}/lua.c ${MY_LUA_Root}/icon/mylua.rc)
target_link_libraries ( lua liblua_share )
install (TARGETS lua liblua_share
        #  ARCHIVE DESTINATION lib
        #  LIBRARY DESTINATION lib
         RUNTIME DESTINATION bin
         )

# luac 只能和 lualib 静态链接. 不想改代码，就这样用着吧
add_executable ( luac ${LUA_SRC_FILES} ${LUA_SRC_PATH}/luac.c ${MY_LUA_Root}/icon/mylua.rc)
install (TARGETS luac
        #  ARCHIVE DESTINATION lib
        #  LIBRARY DESTINATION lib
         RUNTIME DESTINATION bin
         )