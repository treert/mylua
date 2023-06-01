mylua
================

## 想法
- 重新拾起lua，根据自己的喜好定制成mylua，准备作为自己的胶水语言。
  - [mylua](./mylua/README.md)
- 后续的工作
  - 定制下 lsp ，来支持mylua的语法。
  - 为 mylua 扩充标准 api。【如果不用array，会和lua完成兼容。】

## 整合所有库
- git@github.com:treert/lua.git 定制的 MyLua
- git@github.com:lunarmodules/luafilesystem.git
- git@github.com:treert/luasocket.git
- git@github.com:Tencent/LuaPanda.git 调试方案
- https://www.inf.puc-rio.br/~roberto/lpeg/

## 特别的库
lua 相关的一些非常好的开源库。
- https://github.com/LuaLS/lua-language-server
  - 孙颐久大佬开发的 lua lsp。结合类型注释后，lua就非常好用了。
- git@github.com:cloudwu/skynet.git
  - 云风的 skynet