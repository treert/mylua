[my lua](./doc/mylua.md)
--------
## my lua 的主要修改
- 修改了 table 的实现。现在 **table = ordered_map | array**。map is default，是个支持排序的 HashTable。
- 增加了一些语法。[增量语法糖](#增量语法糖)
- 增加了一些 api。[table-newapi](#mylua-table-api)
- 增加稳定排序 [stable sort](#talbestable_sort)
- 一些不兼容的修改。[不兼容修改](#不兼容修改)
- for in 遍历修改了。[for in](#for-in)

### 关于 lua
实现了 map + array + stable_sort 后。
重新看lua，lua的table如果正确使用，性能也是极好的。【当然 for in pairs 的实现需要优化下, 总不能比ipairs 还慢呀】
**因为 ordered_map 多一层索引的问题。mylua的性能比不了lua了。**
不过想到因此带来的收益，还行，也没差太多。空表内存还能小一个8字节指针呢。

感觉 lua 不会修改当前 hash 部分的实现了。虽然**遍历无序且不支持排序**，但是性能好呀。
也许哪天不在乎内存，可以在 hash 节点里增加双向遍历索引，像 php 一样。**感觉也不太可能，lua现在的hash实现性能还是很好的**
lua 的`#`是个问题。也许哪天分离出`array_count`和`hash_count`出来。权衡一下还是可行的。

## 增量语法糖
增加了一些语法糖，兼容性很高
- 增加了一批 `$string $function` 的语法糖。
  - 如：`$"$a ${1+3}" == "nil 4"`
  - 如：`local a = ${print('hello')}`
- 增加了 continue 关键字。
- 增加 ?? 运算。替换`a or 1`这种写法。**有不同的地方，只检测nil，所以`(false??1) == false`**
- 增加 ? 语法糖。替换`t and t.x`这种写法。
  - 例如：`xxx?.xx?:ff?()?[12] ?? 123 == 123`
- keyword 特殊情况下可以当做普通的 name。如：`t.end = 1`
- 函数参数支持命名参数。如：`f(1,2,3,a1=1,a2=2)`
- 增加 array， 作为 table 变种存在。例子：`[1,2,3]`
- 增加`t[]=1`的语法。只支持table
  - 近似于`t[#t+1] = 1`,但是获取长度时不读元表。
- 很小的修改
  - 函数调用和函数定义时参数后面可以增加个一个`,`

## 不兼容修改
- __concat 废弃了。`$string`的实现复用了`OP_CONCAT`指令，修改了 concat 的实现。
- table.pack 返回 array , 不再有 `.n` 了。用 `#t` 获取长度。
- `#`获取长度的指令。`#map`获取hash表元素个数。`#array`获取数组的曾经有效的最大索引。
- `next` 基本还是兼容的。不过 lua 原先的实现有个副作用效果。
  - 已经删除的 key, 大概率还能正确的 next. 现在不行了, 会报错.

### 特殊兼容处理
- table.pack 返回 array，用元表添加了`.n`。最好还是用`#t`获取长度。最快。

## for in
for in 特殊支持 table 的内部索引。**耗时是原先 pairs 的 20%.**
lua 的 pairs 也可以用类似思路修改下实现。
```lua
for k,v in t do
    print(k,v)
end

-- 等价于 pairs(t), 实际修改了 pairs 函数。
for k,v in pairs(t) do
    print(k,v)
end
```

## talbe.stable_sort

增加稳定排序。not in place sort. 耗时差不多sort的一半。**可以分别对map的key或者value排序**
```c
/*
table.stable_sort( t, opt1?, opt2?)。 参数说明：
opt1
- 1   sortbyvalue   ascending order  (default)
- -1  sortbyvalue   descending order
- 2   sortbykey     ascending order
- -2  sortbykey     descending order
- function     opt2 控制函数如何使用
  - 1               cmp(value_a,value_b):number ascending order (default)
  - -1              cmp(value_a,value_b):number descending order
  - 2               cmp(key_a,key_b):number ascending order
  - -2              cmp(key_a,key_b):number descending order
  - 3               getid(k,v):number ascending order 函数返回数字id作为排序依据
  - 3               getid(k,v):number descending order 函数返回数字id作为排序依据
*/
```

特别的是：比较函数返回 `<0, 0, >0`，和 sort是不一样的。

## mylua table api
mylua 把 table 分成了纯粹的 map,array 两个结构。默认是 map。
提供一些API
- `table.newarray(int size)` 可以指定初始容量。最简单的构造是`[1,2,3,4,5]`
- `table.newmap(int size)`
- `table.get_capacity(int size)` 可以容纳的最多的元素个数。可以换算出消耗的内存
- `table.next(t,idx?)` return next_idx,k,v or nil when nomore element.
  - 快速遍历。idx start from 0, 但是应该不用关注。初始传 nil 就行
- `table.ismap(t)`
- `table.isarray(t)`
- `table.shrink(t)` 压缩 table 的空洞。【会尝试减少内存】
- `table.stable_sort(t,opt1,opt2)` 稳定排序。
- `table.push(t,...)`
- `table.pop(t,n?)`
- `table.setsize(t,size)` 
  - array: 真的修改数组大小。
  - map: 相当于 reserve size , 不会修改map内容。

## mylua table 内部实现 
使用类似 dotnet 的 Dictionary 实现方案。功能上更符合我的需要。
- 语义更加明确，不会再有 `#t` 的争执。
- 方便后续优化`forin sort`之类。
- **实现附带的效果：添加的顺序和遍历的顺序一致。**
  - 如果有空洞，添加的元素先进空洞，顺序就靠前了。

特殊说明:
- 默认初始化`{}`如果数组和kv混合，一般是kv在前。但是不保证。
- 当前的实现方案，talbe的内存是固定的若干种。倍增分配。
- array 额外提供的array就是个简单的数组
  - 数组里允许 nil 存在。
  - **数组只能从结尾处加元素。**这样使用起来比较安全，**不然`array[2^30]=1`这个代码会分配16G内存！！！**
  - 性能略低 lua 的array 一点点。【按理应该几乎一样呀】
    - 【有些搞不懂，`array[1000]` 差距达到10%】应该都是基本的数值呀.

通过 array + metatable + map, 可以模拟一个 lua 的 table. 不过性能就堪忧了。
## mylua 性能测试
map 的实现多了一层索引。性能差于lua table。大致 多耗时 10%
性能上有利有弊。测试 [benchmark.lua](./testes/benchmark.lua) 结果如下：
| lua5.4 | mylua  | my/lua  |desc (使用了 mylua定制的array)
| -----  | -----  | --------|-
|1.834   |1.88    |1.03     | Standard (solid)
|2.132   |2.576   |1.21     | Standard (metatable)
|1.844   |1.946   |1.06     | Object using closures (PiL 16.4)
|1.553   |1.546   |1.00     | Object using closures (noself)
|0.294   |0.29    |0.99     | Local Variable
|0.76    |0.861   |1.13     | Direct Access
|2.015   |1.992   |0.99     | table init
|2.095   |1.04    |0.50     | table forin_and_set
|10.021  |9.637   |0.96     | array[2] init
|1.459   |1.616   |1.04     | array[2] reset
|4.802   |2.632   |0.54     | array[2] forin
|7.036   |6.385   |0.90     | array[4] init
|0.97    |1.126   |1.08     | array[4] reset
|3.284   |1.472   |0.44     | array[4] forin
|3.367   |2.912   |0.84     | array[20] init
|0.544   |0.69    |1.08     | array[20] reset
|2.097   |0.532   |0.25     | array[20] forin
|1.302   |1.407   |1.04     | array[200] init
|0.468   |0.589   |1.02     | array[200] reset
|1.822   |0.322   |0.17     | array[200] forin
|0.932   |1.303   |1.15     | array[2000] init
|0.434   |0.596   |1.10     | array[2000] reset
|1.786   |0.291   |0.16     | array[2000] forin
|1.066   |0.154   |0.14     | array[2000] sort vs stable_sort

### 旧的测试数据，包含了 Array 的测试.
[test-performance](./testes/test-performance.lua) 旧的测试代码. 里面包含的不兼容lua的代码。Array 和 lua 纯粹使用数组差不多。
```lua
--[[
测试规模：table_size=1000_000 for_loop=100。PS: lua没有array
测试耗时(mylua/lua)：
    for in                   => 20%
    init map                 => 210%
    init array / lua map     => 110%

具体数据：cmake --config Relese：
mylua:
int array cost 0.011s        0.009s (如果用 table.newarray(size) 初始化)
for array cost 0.270s
init map cost 0.021s         0.016s (如果用 table.newmap(size) 初始化)
for map cost 0.290s
lua:
init map cost 0.010s
for map cost 1.486s
]]
```
# Lua Official

This is the repository of Lua development code, as seen by the Lua team. It contains the full history of all commits but is mirrored irregularly. For complete information about Lua, visit [Lua.org](https://www.lua.org/).

Please **do not** send pull requests. To report issues, post a message to the [Lua mailing list](https://www.lua.org/lua-l.html).

Download official Lua releases from [Lua.org](https://www.lua.org/download.html).
