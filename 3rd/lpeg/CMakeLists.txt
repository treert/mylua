if(WIN32)
    add_definitions("/wd4244")
    add_definitions("/wd4267")
endif(WIN32)

add_library (lpeg SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/src/lpcap.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/lpcode.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/lpprint.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/lptree.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/lpvm.c
    )
target_include_directories(lpeg PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)
# target_compile_definitions ( lpeg PRIVATE _CRT_SECURE_NO_WARNINGS) # 屏蔽 scranf() 不安全的警告
target_link_libraries ( lpeg liblua_share )

install (TARGETS lpeg
        #  ARCHIVE DESTINATION lib
        #  LIBRARY DESTINATION lib
         RUNTIME DESTINATION bin
         )