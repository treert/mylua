cmake_minimum_required(VERSION 3.6)
# fxxk https://stackoverflow.com/questions/6241922/how-to-use-cmake-install-prefix
# 还会突然坏掉，哎。再出一次问题，就在bat里加参数吧。cmake -DCMAKE_INSTALL_PREFIX=C:/MyExe ..
# SET(CMAKE_INSTALL_PREFIX "C:/MyExe" CACHE PATH "my exe dir")

# https://stackoverflow.com/questions/15662497/difference-between-cmake-current-source-dir-and-cmake-current-list-dir
# CMAKE_SOURCE_DIR: Topmost folder(source directory) that contains a CMakeList.txt file. The value never changes in different scopes.
# PROJECT_SOURCE_DIR: The nearest folder that contains CMakeList.txt file, with its own scope, that contains project() command.
# CMAKE_CURRENT_SOURCE_DIR: The nearest folder that contains CMakeList.txt file with its own scope. (File do not need to contain project() command)
# CMAKE_CURRENT_LIST_DIR: The folder that contains currently processed CMakeList.txt or .cmake file.

set(CMAKE_C_STANDARD 17)

# https://zhuanlan.zhihu.com/p/616871895 稍微清楚点
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)  # C++ 11 是强制要求，不会衰退至低版本
set(CMAKE_CXX_EXTENSIONS OFF)  # 禁止使用编译器特有扩展

project(mylua)

add_subdirectory(mylua)

add_subdirectory(3rd/lpeg)
add_subdirectory(3rd/luafilesystem)
add_subdirectory(3rd/luasocket)
