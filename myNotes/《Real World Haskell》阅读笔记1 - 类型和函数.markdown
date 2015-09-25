#《Real World Haskell》阅读笔记1 - 类型和函数



##Haskell 的类型系统

Haskell 中的类型有三个有趣的方面：首先，它们是**强（strong）类型**的；其次，它们是**静态（static）**的；第三，它们**可以通过自动推导（automatically inferred）得出**。

要在 Haskell 中进行类型转换，必须显式地使用类型转换函数。

静态类型系统指的是，编译器可以在编译期（而不是执行期）知道每个值和表达式的类型。Haskell 编译器或解释器会察觉出类型不正确的表达式，并拒绝这些表达式的执行。

Haskell 提供的 typeclass 机制以一种安全、方便、实用的方式提供了大部分动态类型的优点。Haskell 也提供了一部分对全动态类型（truly dynamic types）编程的支持，尽管用起来没有专门支持这种功能的语言那么方便。

要理解静态类型的好处，可以用玩拼图的例子来打比方：在 Haskell 里，如果一块拼图的形状不正确，那么它就不能被使用。另一方面，动态类型的拼图全部都是 1 x 1 大小的正方形，这些拼图无论放在那里都可以匹配，为了验证这些拼图被放到了正确的地方，必须使用测试来进行检查。

因为 Haskell 里值和函数的类型都可以通过自动推导得出，所以 Haskell 程序既可以获得静态类型带来的所有好处，而又不必像传统的静态类型语言那样，忙于添加各种各样的类型签名（比如 C 语言的函数原型声明）

##一些常用的基本类型

`Char`
单个 Unicode 字符。

`Bool`
表示一个布尔逻辑值。这个类型只有两个值： True 和 False 。

`Int`
带符号的定长（fixed-width）整数。这个值的准确范围由机器决定：在 32 位机器里， Int 为 32 位宽，在 64 位机器里， Int 为 64 位宽。Haskell 保证 Int 的宽度不少于 28 位。（数值类型还可以是 8 位、16 位，等等，也可以是带符号和无符号的，以后会介绍。）

`Integer`
不限长度的带符号整数。 Integer 并不像 Int 那么常用，因为它们需要更多的内存和更大的计算量。另一方面，对 Integer 的计算不会造成溢出，因此使用 Integer 的计算结果更可靠。

`Double`
用于表示浮点数。长度由机器决定，通常是 64 位。（Haskell 也有 Float 类型，但是并不推荐使用，因为编译器都是针对 Double 来进行优化的，而 Float 类型值的计算要慢得多。）

在前面的章节里，我们已经见到过 `::` 符号。除了用来表示类型之外，它还可以用于进行类型签名。比如说， `exp :: T` 就是向 Haskell 表示， exp 的类型是 `T` ，而 `:: T` 就是表达式 exp 的类型签名。如果一个表达式没有显式地指名类型的话，那么它的类型就通过自动推导来决定：
```
Prelude> :type 'a'
'a' :: Char

Prelude> 'a'            -- 自动推导
'a'

Prelude> 'a' :: Char    -- 显式签名
'a'
```
当然了，类型签名必须正确，否则 Haskell 编译器就会产生错误：
```
Prelude> 'a' :: Int     -- 试图将一个字符值标识为 Int 类型

<interactive>:7:1:
    Couldn't match expected type `Int' with actual type `Char'
    In the expression: 'a' :: Int
    In an equation for `it': it = 'a' :: Int
```

##复合数据类型

因为列表中的值可以是任意类型，所以我们可以称列表为**类型多态（polymorphic）**的。当需要编写带有多态类型的代码时，需要使用类型变量。**这些类型变量以小写字母开头，作为一个占位符，最终被一个具体的类型替换。**

比如说， [a] 用一个方括号包围一个类型变量 a ，表示一个“类型为 a 的列表”。这也就是说“我不在乎列表是什么类型，尽管给我一个列表就是了”。

当需要一个带有具体类型的列表时，就需要用一个具体的类型去替换类型变量。比如说， [Int] 表示一个包含 Int 类型值的列表，它用 Int 类型替换了类型变量 a 。又比如， [MyPersonalType] 表示一个包含 MyPersonalType 类型值的列表，它用 MyPersonalType 替换了类型变量 a 。

这种替换还还可以递归地进行： [[Int]] 是一个包含 [Int] 类型值的列表，而 [Int] 又是一个包含 Int 类型值的列表。以下例子展示了一个包含 Bool 类型的列表的列表：
```
Prelude> :type [[True], [False, False]]
[[True], [False, False]] :: [[Bool]]
```
假设现在要用一个数据结构，分别保存一本书的出版年份 —— 一个整数，以及这本书的书名 —— 一个字符串。很明显，列表不能保存这样的信息，因为列表只能接受类型相同的值。这时，我们就需要使用元组：
```
Prelude> (1964, "Labyrinths")
(1964,"Labyrinths")
```
元组和列表非常不同，它们的两个属性刚刚相反：**列表可以任意长，且只能包含类型相同的值；元组的长度是固定的，但可以包含不同类型的值。**

###处理列表和元组的函数
函数 `take` 和 `drop` 接受两个参数，一个数字 n 和一个列表 l 。

take 返回一个包含 l 前 n 个元素的列表：
```
Prelude> take 2 [1, 2, 3, 4, 5]
[1,2]
```
drop 则返回一个包含 l 丢弃了前 n 个元素之后，剩余元素的列表：
```
Prelude> drop 2 [1, 2, 3, 4, 5]
[3,4,5]
```
函数 `fst` 和 `snd` 接受一个元组作为参数，返回该元组的第一个元素和第二个元素：
```
Prelude> fst (1, 'a')
1

Prelude> snd (1, 'a')
'a'
```

###将表达式传给函数

Haskell 的函数应用是左关联的。比如说，表达式 `a b c d` 等同于 `(((a b) c) d)` 。要将一个表达式用作另一个表达式的参数，那么就必须显式地使用括号来包围它，这样编译器才会知道我们的真正意思：
```
Prelude> head (drop 4 "azety")
'y'
```

###函数类型

使用 `:type` 命令可以查看函数的类型[译注：缩写形式为 :t ]：
```
Prelude> :type lines
lines :: String -> [String]
```
符号 `->` 可以读作“映射到”，或者（稍微不太精确地），读作“返回”。函数的类型签名显示， lines 函数接受单个字符串，并返回包含字符串值的列表：
```
Prelude> lines "the quick\nbrown fox\njumps"
["the quick","brown fox","jumps"]
```
结果表示， lines 函数接受一个字符串作为输入，并将这个字符串按行转义符号分割成多个字符串。

从 lines 函数的这个例子可以看出：函数的类型签名对于函数自身的功能有很大的提示作用，这种属性对于函数式语言的类型来说，意义重大。

###纯度
Haskell 的函数在默认情况下都是无副作用的：函数的结果只取决于显式传入的参数。

我们将带副作用的函数称为“不纯（impure）函数”，而将不带副作用的函数称为“纯（pure）函数”。

从类型签名可以看出一个 Haskell 函数是否带有副作用 —— 不纯函数的类型签名都以 IO 开头：
```
Prelude> :type readFile
readFile :: FilePath -> IO String
```

##函数
符号 `=` 表示将左边的名字（函数名和函数参数）定义为右边的表达式（函数体）。

##变量
在 Haskell 里，可以使用变量来赋予表达式名字：一旦变量绑定了（也即是，关联起）某个表达式，那么这个变量的值就不会改变 —— 我们总能用这个变量来指代它所关联的表达式，并且每次都会得到同样的结果。
```
-- file: ch02/Assign.hs
x = 10
x = 11
```
Haskell 并不允许做这样的多次赋值：
```
Prelude> :load Assign
[1 of 1] Compiling Main             ( Assign.hs, interpreted )

Assign.hs:3:1:
    Multiple declarations of `x'
    Declared at: Assign.hs:2:1
                 Assign.hs:3:1
Failed, modules loaded: none.
```

##条件求值

和很多语言一样，Haskell 也有自己的 if 表达式。本节先说明怎么用这个表达式，然后再慢慢介绍它的详细特性。

我们通过编写一个个人版本的 drop 函数来熟悉 if 表达式。先来回顾一下 drop 的行为：
```
Prelude> drop 2 "foobar"
"obar"

Prelude> drop 4 "foobar"
"ar"

Prelude> drop 4 [1, 2]
[]

Prelude> drop 0 [1, 2]
[1,2]

Prelude> drop 7 []
[]

Prelude> drop (-2) "foo"
"foo"
```
从测试代码的反馈可以看到。当 drop 函数的第一个参数小于或等于 0 时， drop 函数返回整个输入列表。否则，它就从列表左边开始移除元素，一直到移除元素的数量足够，或者输入列表被清空为止。

以下是带有同样行为的 myDrop 函数，它使用 if 表达来决定该做什么。而代码中的 null 函数则用于检查列表是否为空：
```
-- file: ch02/myDrop.hs
myDrop n xs = if n <= 0 || null xs
              then xs
              else myDrop (n - 1) (tail xs)
```
在 Haskell 里，代码的缩进非常重要：它会延续（continue）一个已存在的定义，而不是新创建一个。所以，不要省略缩进！

变量 xs 展示了一个命名列表的常见模式： s 可以视为后缀，而 xs 则表示“复数个 x ”。

先保存文件，试试 myDrop 函数是否如我们所预期的那样工作：
```
Prelude> :load myDrop.hs
[1 of 1] Compiling Main             ( myDrop.hs, interpreted )
Ok, modules loaded: Main.

*Main> myDrop 2 "foobar"
"obar"

*Main> myDrop 4 "foobar"
"ar"

*Main> myDrop 4 [1, 2]
[]

*Main> myDrop 0 [1, 2]
[1,2]

*Main> myDrop 7 []
[]

*Main> myDrop (-2) "foo"
"foo"
```

我们将跟在 then 和 else 之后的表达式称为“分支”。不同分支之间的类型必须相同。像是 `if True then 1 else "foo"` 这样的表达式会产生错误，因为两个分支的类型并不相同。

##了解求值

用于追踪未求值表达式的记录被称为块（thunk）。这就是事情发生的经过：编译器通过创建块来延迟表达式的求值，直到这个表达式的值真正被需要为止。如果某个表达式的值不被需要，那么从始至终，这个表达式都不会被求值。

非严格求值通常也被称为惰性求值。

纯度减轻了理解一个函数所需的工作量。一个纯函数的行为并不取决于全局变量、数据库的内容或者网络连接状态。纯代码（pure code）从一开始就是模块化的：每个函数都是自包容的，并且都带有定义良好的接口。