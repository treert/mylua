if(WIN32)
    add_definitions("/wd4996")
endif(WIN32)

set(LUA_SOCKET_INC_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(LUA_SOCKET_SRC_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src)
set (LUA_SOCKET_SRC_FILES
    ${LUA_SOCKET_SRC_PATH}/auxiliar.c
    ${LUA_SOCKET_SRC_PATH}/buffer.c
    ${LUA_SOCKET_SRC_PATH}/except.c
    ${LUA_SOCKET_SRC_PATH}/inet.c
    ${LUA_SOCKET_SRC_PATH}/io.c
    ${LUA_SOCKET_SRC_PATH}/luasocket.c
    ${LUA_SOCKET_SRC_PATH}/options.c
    ${LUA_SOCKET_SRC_PATH}/select.c
    ${LUA_SOCKET_SRC_PATH}/tcp.c
    ${LUA_SOCKET_SRC_PATH}/timeout.c
    ${LUA_SOCKET_SRC_PATH}/udp.c
)

set (LUA_SOCKET_MINE_FILES
    ${LUA_SOCKET_SRC_PATH}/mime.c
)

# https://blog.csdn.net/sean_8180/article/details/81189996

IF (WIN32)
    set(LUA_SOCKET_TCP_FILES ${LUA_SOCKET_SRC_PATH}/wsocket.c)
ELSEIF ()
    set(LUA_SOCKET_TCP_FILES 
        ${LUA_SOCKET_SRC_PATH}/usocket.c
        ${LUA_SOCKET_SRC_PATH}/unix.c
        ${LUA_SOCKET_SRC_PATH}/unixdgram.c
        ${LUA_SOCKET_SRC_PATH}/unixstream.c
        ${LUA_SOCKET_SRC_PATH}/serial.c
    )
endif()

add_library (luasocket SHARED ${LUA_SOCKET_SRC_FILES} ${LUA_SOCKET_TCP_FILES})
target_include_directories(luasocket PUBLIC ${LUA_SOCKET_INC_PATH})
target_link_libraries ( luasocket liblua_share )
target_compile_definitions ( luasocket PRIVATE _CRT_SECURE_NO_WARNINGS) # 屏蔽 scranf() 不安全的警告
set_target_properties ( luasocket PROPERTIES OUTPUT_NAME core )

IF (WIN32)
    target_link_libraries(luasocket wsock32 ws2_32)
ELSEIF (APPLE)
    target_compile_definitions(luasocket PRIVATE UNIX_HAS_SUN_LEN)
ELSEIF (UNIX)
endif()

install (TARGETS luasocket
#  ARCHIVE DESTINATION lib
#  LIBRARY DESTINATION lib
RUNTIME DESTINATION bin/socket
)


add_library (luamine SHARED ${LUA_SOCKET_MINE_FILES})
target_include_directories(luamine PUBLIC ${LUA_SOCKET_INC_PATH})
target_link_libraries ( luamine liblua_share )
set_target_properties ( luamine PROPERTIES OUTPUT_NAME core )

IF (WIN32)
ELSEIF (APPLE)
    target_compile_definitions(luamine PRIVATE UNIX_HAS_SUN_LEN)
ELSEIF (UNIX)
endif()

install (TARGETS luamine
    #  ARCHIVE DESTINATION lib
    #  LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin/mine
    )
    