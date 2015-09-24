# 《Real World Haskell》阅读笔记0 - 入门

标签（空格分隔）： haskell

---

[TOC]

##初识解释器ghci

模块Prelude有时候被称为“标准序幕”(the standard prelude)，因为它的内容是基于Haskell 98标准定义的。通常简称它为“序幕”(the prelude)。

>Note
关于ghci的提示符
提示符经常是随着模块的加载而变化。因此经常会变得很长以至在单行中没有太多可视区域用来输入。
为了简单和一致起见，在本书中我们会用字符串 ‘ghci>’ 来替代ghci的默认提示符。
你可以用ghci的 :set prompt 来进行修改。
```
Prelude> :set prompt "ghci>"
ghci>
```
prelude模块中的类型，值和函数是默认直接可用的，在使用之前我们不需要额外的操作。然而如果需要其他模块中的一些定义，则需要使用ghci的`:module`方法预先加载。
```
ghci> :module + Data.Ratio
```
现在我们就可以使用Data.Ratio模块中的功能了。这个模块提供了一些操作有理数的功能。

##基本数学运算

用中缀表达式是为了书写方便：我们同样可以用前缀表达式，即操作符在操作数之前。在这种情况下，我们需要用括号将操作符括起来。
```
ghci> 2 + 2
4
ghci> (+) 2 2
4
```
上述的这些表达式暗示了一个概念，Haskell有**整数**和**浮点数**类型。**整数的大小是随意的**。下面例子中的(^)表示了整数的乘方。
```
ghci> 313 ^ 15
27112218957718876716220410905036741257
```
C语言中是用`!=`表示的，而Haskell是用`/=`表示的，它看上去很像数学中的≠。
另外，类C的语言中通常用`!`表示逻辑非的操作，而Haskell中用函数`not`。
```
ghci> not True
False
```
Haskell给每个操作符一个数值型的优先级值，从1表示最低优先级，到9表示最高优先级。高优先级的操作符先于低优先级的操作符被应用(apply)。在ghci中我们可以用命令`:info`来查看某个操作符的优先级。
```
ghci> :info (+)
class (Eq a, Show a) => Num a where
  (+) :: a -> a -> a
  ...
    -- Defined in GHC.Num
infixl 6 +
ghci> :info (*)
class (Eq a, Show a) => Num a where
  ...
  (*) :: a -> a -> a
  ...
    -- Defined in GHC.Num
infixl 7 *
```
这里我们需要找的信息是`infixl 6 +`，表示(+)的优先级是6。（其他信息我们稍后介绍。）`infixl 7 *`表示(*)的优先级为7。由于(*)比(+)优先级高，所以我们看到为什么`1 + 4 * 4`和`1 + (4 * 4)`值相同而不是`(1 + 4) * 4`。

Haskell也定义了操作符的**结合性(associativity)**。它决定了当一个表达式中多次出现某个操作符时是否是从左到右求值。(+)和(*)都是左结合，在上述的ghci输出结果中以`infixl`表示。一个右结合的操作符会以`infixr`表示。
```
ghci> :info (^)
(^) :: (Num a, Integral b) => a -> b -> a   -- Defined in GHC.Real
infixr 8 ^
```
优先级和结合性规则的组合通常称之为**固定性(fixity)规则**。

##定义变量

Haskell的标准库`prelude`定义了至少一个大家熟知的数学常量。
```
ghci> pi
3.141592653589793
```
然后我们很快就会发现它对数学常量的覆盖并不是很广泛。让我们来看下Euler数，e。
```
ghci> e

<interactive>:1:0: Not in scope: `e'
```
啊哈，看上去我们必须得自己定义。

>以上“not in the scope”的错误信息看上去有点令人畏惧的。别担心，它所要表达的只是没有用e这个名字定义过变量。

使用ghci的`let`构造(contruct)，我们可以定义一个临时变量e。
```
ghci> let e = exp 1
```
这是指数函数`exp`的一个应用，也是如何调用一个Haskell函数的第一个例子。 像Python这些语言，函数的参数是位于括号内的，但Haskell不要那样。

既然e已经定义好了，我们就可以在数学表达式中使用它。我们之前用到的乘方操作符(^)是对于整数的。**如果要用浮点数作为指数，则需要操作符`**`。**
```
ghci> (e ** pi) - pi
19.99909997918947
```

>ghci 中 let 的语法和常规的“top level”的Haskell程序的使用不太一样。我们会在章节“初识类型”里看到常规的语法形式。

如果用列举符号(**enumeration notation**)来表示一系列元素，Haskell则会自动填充内容。
```
ghci> [1.0,1.25..2.0]
[1.0,1.25,1.5,1.75,2.0]

ghci> [1,4..15]
[1,4,7,10,13]

ghci> [10,9..1]
[10,9,8,7,6,5,4,3,2,1]
```

>浮点数在任何语言里都显得有些怪异(quirky)，Haskell也不例外。
>字符串就是字符的列表

##初识类型

在 Haskell里，所有类型名字都以大写字母开头，而所有变量名字都以小写字母开头。紧记这一点，你就不会弄错类型和变量。

我们探索类型世界的第一步是修改 ghci，让它在返回表达式的求值结果时，打印出这个结果的类型。使用 ghci 的 `:set`命令可以做到这一点：
```
Prelude> :set +t

Prelude> 'c'    -- 输入表达式
'c'             -- 输出值
it :: Char      -- 输出值的类型

Prelude> "foo"
"foo"
it :: [Char]
```
注意打印信息中那个神秘的 `it ：`这是一个有特殊用途的变量， ghci将最近一次求值所得的结果保存在这个变量里。（这不是 Haskell语言的特性，只是 ghci 的一个辅助功能而已。）

Haskell 的整数类型为 Integer 。 Integer 类型值的长度只受限于系统的内存大小。

分数和整数看上去不太相同，它使用 `%` 操作符构建，其中分子放在操作符左边，而分母放在操作符右边：
```
Prelude> :m +Data.Ratio
Prelude Data.Ratio> 11 % 29
11 % 29
it :: Ratio Integer
```
为了方便用户， ghci 允许我们对很多命令进行缩写，这里的 `:m` 就是 `:module` 的缩写，它用于载入给定的模块。

注意这个分数的类型信息：在 : : 的右边，有两个单词，分别是 Ratio 和 Integer ，可以将这个类型读作“由整数构成的分数”。这说明，分数的分子和分母必须都是整数类型。

尽管每次都打印出值的类型很方便，但这实际上有点小题大作了。因为在一般情况下，表达式的类型并不难猜，或者我们并非对每个表达式的类型都感兴趣。所以这里用 `:unset` 命令取消对类型信息的打印：
```
Prelude Data.Ratio> :unset +t

Prelude Data.Ratio> 2
2
```
取而代之的是，如果现在我们对某个值或者表达式的类型不清楚，那么可以用 `:type` 命令显式地打印它的类型信息：
```
Prelude Data.Ratio> :type 'a'
'a' :: Char

Prelude Data.Ratio> "foo"
"foo"

Prelude Data.Ratio> :type it
it :: [Char]
```
注意 `:type` 并不实际执行传给它的表达式，它只是对输入进行检查，然后将输入的类型信息打印出来。以下两个例子显示了其中的区别：
```
Prelude Data.Ratio> 3 + 2
5

Prelude Data.Ratio> :type it
it :: Integer

Prelude Data.Ratio> :type 3 + 2
3 + 2 :: Num a => a
```
在前两个表达式中，我们先求值 `3+2` ，再使用 `:type` 命令打印 `it` 的类型，因为这时 `it` 已经是 3+2 的结果 5 ，所以 `:type` 打印这个值的类型 `it :: Integer` 。

另一方面，最后的表达式中，我们直接将 3+2 传给 `:type` ，而 `:type` 并不对输入进行求值，因此它返回表达式的类型 `3 + 2 :: Num a => a` 。

##行计数程序

以下是一个用 Haskell 写的行计数程序。如果暂时看不太懂源码也没关系，先照着代码写写程序，热热身就行了。

使用编辑器，输入以下内容，并将它保存为 WC.hs ：
```
-- file: ch01/WC.hs
-- lines beginning with "--" are comments.

main = interact wordCount
    where wordCount input = show (length (lines input)) ++ "\n"
```
再创建一个 quux.txt ，包含以下内容：
```
Teignmouth, England
Paris, France
Ulm, Germany
Auxerre, France
Brunswick, Germany
Beaumont-en-Auge, France
Ryazan, Russia
```
然后，在 shell 执行以下代码：
```
$ runghc WC < quux.txt
7
```
