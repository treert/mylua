--[[header
    > File Name: copy-src.lua
    > Create Time: 2023-05-27 星期六 17时40分26秒
    > Author: onemore
]]
--[[
    定制拷贝建立一些目录。
]]

local config = {
    -- lua = true,
    -- lfs = true,
    -- socket = true,
}

require "lfs"

-- Split a string into a table using a delimiter. ignore empty seg.
-- https://stackoverflow.com/questions/1426954/split-string-in-lua
---@param str string
---@param pat string
---@return table
string.split = function(str, pat)
    local t = []
    local fpat = pat
    local last_end = 1
    local s, e = str:find(fpat, 1)
    while s do
        if s > last_end then
            t[] = str:sub(last_end, s - 1)
        end

        last_end = e+1
        s, e = str:find(fpat, last_end)
    end

    if last_end <= #str then
        cap = str:sub(last_end)
        t[] = cap
    end

    return t
end

--- 打开或者创建文件。其实是想来复制文件的。发现竟然挺麻烦的。
---@param dir string
---@param in_path string
---@param is_read boolean
---@return file*
local function openfile(in_path,is_read)
    if is_read then
        if not lfs.attributes(in_path) then
            error($"${in_path} not exsit")
        end
        return io.open(in_path, "rb")
    end
    local segs = in_path:split('[/\\]')
    local dir, filename, start_seg = segs[1], segs[#segs], 2
    if #segs == 0 then
        dir = "."
        start_seg = 1
    end
    if not lfs.attributes(dir) then
        error($"${dir} not exsit")
    end
    local path = dir
    for idx = start_seg, #segs - 1 do
        local seg = segs[idx]
        path = path..'/'..seg
        if not lfs.attributes(path) then
            local ok = lfs.mkdir(path)
            if not ok then
                error($"create ${path} failed")
            end
        end
    end
    return io.open(path..'/'..filename,"wb")
end

local function copyfile(src,dst)
    local sf <close>  = openfile(src, true)
    local df <close>  = openfile(dst)
    local content = sf:read("a")
    df:write(content)
end

local function is_file(path)
    local attr = lfs.attributes(path)
    if attr then
        return attr.mode == "file"
    end
end

local function is_dir(path)
    local attr = lfs.attributes(path)
    if attr then
        return attr.mode ~= "file"
    end
end

local function copydir(src,dst)
    for file in lfs.dir(src) do
        local path = src..'/'..file
        if is_file(path) then
            copyfile(path, dst..'/'..file)
        end
    end
end

if not lfs.attributes("./copy-src.lua") then
    error("need run in dir where copy-src.lua in")
end

if config.lua and is_dir("../lua") then
    local srcs = {'lapi.c','lcorolib.c','ldo.c','linit.c','lmem.c','loslib.c','lstrlib.c',
    'ltm.c','lutf8lib.c','lauxlib.c','lctype.c','ldump.c','liolib.c','loadlib.c','lparser.c',
    'ltable.c','lua.c','lvm.c','lbaselib.c','ldblib.c','lfunc.c','llex.c',
    'lobject.c','lstate.c','ltablib.c','luac.c','lzio.c','lcode.c','ldebug.c',
    'lgc.c','lmathlib.c','lopcodes.c','lstring.c','ltests.c','lundump.c','onelua.c',}
    
    local heads = {'lapi.h', 'lctype.h', 'lfunc.h', 'llex.h', 'lobject.h', 'lparser.h', 'lstring.h',
    'ltm.h','lualib.h','lzio.h','lauxlib.h','ldebug.h','lgc.h','llimits.h',
    'lopcodes.h','lprefix.h','ltable.h','lua.h','lundump.h','lcode.h','ldo.h','ljumptab.h',
    'lmem.h','lopnames.h','lstate.h','ltests.h','luaconf.h','lvm.h',}

    for _,file in srcs do
        copyfile("../lua/"..file,"./mylua/src/"..file)
    end

    for _,file in heads do
        copyfile("../lua/"..file,"./mylua/src/"..file)
    end
    print "copy lua finish"
end

if config.lfs and is_dir("../luafilesystem") then
    copyfile("../luafilesystem/src/lfs.c","./3rd/luafilesystem/src/lfs.c")
    copyfile("../luafilesystem/src/lfs.h","./3rd/luafilesystem/src/lfs.h")

    copydir("../luafilesystem/docs","./3rd/luafilesystem/docs")

    print "copy luafilesystem finish"
end

if config.socket and is_dir("../luasocket") then
    local cs = {'auxiliar.c','compat.c','inet.c','luasocket.c','options.c',
    'serial.c','timeout.c','unix.c','unixstream.c','wsocket.c','buffer.c','except.c',
    'io.c','mime.c','select.c','tcp.c','udp.c','unixdgram.c','usocket.c',}

    local hs = {'auxiliar.h','compat.h','inet.h','luasocket.h','options.h',
        'select.h','tcp.h','udp.h','unixdgram.h','usocket.h','buffer.h',
        'except.h','io.h','mime.h','pierror.h','socket.h','timeout.h',
        'unix.h','unixstream.h','wsocket.h',}
        
    local luas = {'ftp.lua','headers.lua','http.lua','ltn12.lua','mbox.lua',
        'mime.lua','smtp.lua','socket.lua','tp.lua','url.lua',}

    for _,file in cs do
        copyfile("../luasocket/src/"..file,"./3rd/luasocket/src/"..file)
    end
    for _,file in hs do
        copyfile("../luasocket/src/"..file,"./3rd/luasocket/src/"..file)
    end
    for _,file in luas do
        copyfile("../luasocket/src/"..file,"./runtime/bin/lua/"..file)
    end
    
    copydir("../luasocket/docs","./3rd/luasocket/docs")

    print "copy luasocket finish"
end
