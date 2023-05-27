if(WIN32)
    add_definitions("/wd4267")
endif(WIN32)

add_library (lfs SHARED ${CMAKE_CURRENT_SOURCE_DIR}/src/lfs.c)
target_include_directories(lfs PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_compile_definitions ( lfs PRIVATE _CRT_SECURE_NO_WARNINGS) # 屏蔽 scranf() 不安全的警告
target_link_libraries ( lfs liblua_share )

install (TARGETS lfs
        #  ARCHIVE DESTINATION lib
        #  LIBRARY DESTINATION lib
         RUNTIME DESTINATION bin
         )