# 《Real World Haskell》阅读笔记2 - Defining Types, Streamlining Functions

标签（空格分隔）： haskell

---

##定义新的数据类型

使用 `data` 关键字可以定义新的数据类型：
```
-- file: ch03/BookStore.hs
data BookInfo = Book Int String [String]
                deriving (Show)
```
跟在 `data` 关键字之后的 `BookInfo` 就是新类型的名字，我们称 `BookInfo` 为**类型构造器**。类型构造器用于指代（refer）类型。正如前面提到过的，类型名字的首字母必须大写，因此，类型构造器的首字母也必须大写。

接下来的 `Book` 是**值构造器（有时候也称为数据构造器）**的名字。类型的值就是由值构造器创建的。值构造器名字的首字母也必须大写。

在 `Book` 之后的 `Int` ， `String` 和 `[String]` 是类型的组成部分。组成部分的作用，和面向对象语言的类中的域作用一致：它是一个储存值的槽。（为了方便起见，我们通常也将组成部分称为域。）

在这个例子中， `Int` 表示一本书的 ID ，而 `String` 表示书名，而 `[String]` 则代表作者。

可以将值构造器看作是一个函数 —— 它创建并返回某个类型值。在这个书店的例子里，我们将 Int 、 String 和 [String] 三个类型的值应用到 Book ，从而创建一个 BookInfo 类型的值：
```
-- file: ch03/BookStore.hs
myInfo = Book 9780135072455 "Algebra of Programming"
              ["Richard Bird", "Oege de Moor"]
```
在 ghci 里，变量通过 let 定义：
```
*Main> let cities = Book 173 "Use of Weapons" ["Iain M. Banks"]
```
使用 `:info` 命令可以查看更多关于给定表达式的信息：
```
*Main> :info BookInfo
data BookInfo = Book Int String [String]
    -- Defined at BookStore.hs:2:6
    instance Show BookInfo -- Defined at BookStore.hs:3:27
```
使用 `:type` 命令，可以查看值构造器 Book 的类型签名，了解它是如何创建出 BookInfo 类型的值的：
```
*Main> :type Book
Book :: Int -> String -> [String] -> BookInfo
```

###类型构造器和值构造器的命名

在 Haskell 里，类型的名字（类型构造器）和值构造器的名字是相互独立的。**类型构造器只能出现在类型的定义，或者类型签名当中。而值构造器只能出现在实际的代码中。**因为存在这种差别，给类型构造器和值构造器赋予一个相同的名字实际上并不会产生任何问题。

##类型别名

可以使用类型别名，来为一个已存在的类型设置一个更具描述性的名字。

比如说，在前面 BookReview 类型的定义里，并没有说明 String 成分是干什么用的，通过类型别名，可以解决这个问题：
```
-- file: ch03/BookStore.hs
type CustomerID = Int
type ReviewBody = String

data BetterReview = BetterReview BookInfo CustomerID ReviewBody
```
`type` 关键字用于设置类型别名，其中新的类型名字放在 = 号的左边，而已有的类型名字放在 = 号的右边。这两个名字都标识同一个类型，因此，类型别名完全是为了提高可读性而存在的。

类型别名也可以用来为啰嗦的类型设置一个更短的名字：
```
-- file: ch03/BookStore.hs
type BookRecord = (BookInfo, BookReview)
```
需要注意的是，类型别名只是为已有类型提供了一个新名字，创建值的工作还是由原来类型的值构造器进行。

##algebraic data type(代数数据类型)
```
e: ch03/Bool.hs
data Bool = False | True
```
上面代码定义的 Bool 类型拥有两个值构造器，一个是 True ，另一个是 False 。每个值构造器使用 | 符号分割，读作“或者” —— 以 Bool 类型为例子，我们可以说， Bool 类型由 True 值或者 False 值构成。

当一个类型拥有一个以上的值构造器时，这些值构造器通常被称为“备选”（alternatives）或“分支”（case）。同一类型的所有备选，创建出的的值的类型都是相同的。

代数数据类型的各个值构造器都可以接受任意个数的参数。以下是一个账单数据的例子：
```
-- file: ch03/BookStore.hs
type CardHolder = String
type CardNumber = String
type Address = [String]
data BillingInfo = CreditCard CardNumber CardHolder Address
                 | CashOnDelivery
                 | Invoice CustomerID
                   deriving (Show)
```
这个程序提供了三种付款的方式。如果使用信用卡付款，就要使用 CreditCard 作为值构造器，并输入信用卡卡号、信用卡持有人和地址作为参数。如果即时支付现金，就不用接受任何参数。最后，可以通过货到付款的方式来收款，在这种情况下，只需要填写客户的 ID 就可以了。

##模式匹配

这个函数计算出列表所有元素之和：
```
-- file:: ch03/sumList.hs
sumList (x:xs) = x + sumList xs
sumList []  = 0
```

需要说明的一点是，在 Haskell 里，列表 [1, 2] 实际上只是 (1:(2:[])) 的一种简单的表示方式，其中 (:) 用于构造列表：
```
Prelude> []
[]

Prelude> 1:[]
[1]

Prelude> 1:2:[]
[1,2]
```
因此，当需要对一个列表进行匹配时，也可以使用 `(:)` 操作符，只不过这次不是用来构造列表，而是用来分解列表。

作为例子，考虑求值 sumList [1, 2] 时会发生什么：首先， [1, 2] 尝试对第一个等式的模式 (x:xs) 进行匹配，结果是模式匹配成功，并将 x 绑定为 1 ， xs 绑定为 [2] 。

计算进行到这一步，表达式就变成了 1 + (sumList [2]) ，于是递归调用 sumList ，对 [2] 进行模式匹配。

这一次也是在第一个等式匹配成功，变量 x 被绑定为 2 ，而 xs 被绑定为 [] 。表达式变为 1 + (2 + sumList []) 。

再次递归调用 sumList ，输入为 [] ，这一次，第二个等式的 [] 模式匹配成功，返回 0 ，整个表达式为 1 + (2 + (0)) ，计算结果为 3 。

最后要说的一点是，标准函数库里已经有 sum 函数，它和我们定以的 sumList 一样，都可以用于计算表元素的和：
```
Prelude> :load sumList.hs
[1 of 1] Compiling Main             ( sumList.hs, interpreted )
Ok, modules loaded: Main.

*Main> sumList [1, 2]
3

*Main> sum [1, 2]
3
```

模式匹配的过程就像是逆转一个值的构造（construction）过程，因此它有时候也被称为**解构（deconstruction）**。

###更进一步

对代数数据类型的匹配，可以通过这个类型的值构造器来进行。拿之前我们定义的 BookInfo 类型为例子，对它的模式匹配可以使用它的 Book 构造器来进行：
```
-- file: ch03/BookStore.hs
bookID      (Book id title authors) = id
bookTitle   (Book id title authors) = title
bookAuthors (Book id title authors) = authors
```
在 ghci 里试试：
```
Prelude> :load BookStore.hs
[1 of 1] Compiling Main             ( BookStore.hs, interpreted )
Ok, modules loaded: Main.

*Main> let book = (Book 3 "Probability Theory" ["E.T.H. Jaynes"])

*Main> bookID book
3

*Main> bookTitle book
"Probability Theory"

*Main> bookAuthors book
["E.T.H. Jaynes"]
```
字面值的比对规则对于列表和值构造器的匹配也适用： (3:xs) 模式只匹配那些不为空，并且第一个元素为 3 的列表；而 (Book 3 title authors) 只匹配 ID 值为 3 的那本书。

###模式匹配中的变量名命名

当你阅读那些进行模式匹配的函数时，经常会发现像是 (x:xs) 或是 (d:ds) 这种类型的名字。这是一个流行的命名规则，其中的 s 表示“元素的复数”。以 (x:xs) 来说，它用 x 来表示列表的第一个元素，剩余的列表元素则用 xs 表示。

###穷举匹配模式和通配符

如果在某些情况下，我们并不在乎某些特定的构造器，我们就可以用通配符匹配模式来定义一个默认的行为。
```
-- file: ch03/BadPattern.hs
goodExample (x:xs) = x + goodExample xs
goodExample _      = 0
```
上面例子中的通配符可以匹配 [] 构造器，因此应用这个函数不会导致程序崩溃。
```
ghci> goodExample []
0
ghci> goodExample [1,2]
3
```

##记录语法

程序部分见/chap03/bookStore.hs

我们在使用记录语法的时候“免费”得到的访问器函数，实际上都是普通的 Haskell 函数。
```
ghci> :type customerName
customerName :: Customer -> String
ghci> customerName customer1
"J.R. Hacker"
```

标准库里的 System.Time 模块就是一个使用记录语法的好例子。例如其中定义了这样一个类型：
```
data CalendarTime = CalendarTime {
  ctYear                      :: Int,
  ctMonth                     :: Month,
  ctDay, ctHour, ctMin, ctSec :: Int,
  ctPicosec                   :: Integer,
  ctWDay                      :: Day,
  ctYDay                      :: Int,
  ctTZName                    :: String,
  ctTZ                        :: Int,
  ctIsDST                     :: Bool
}
```
假如没有记录语法，从一个如此复杂的类型中抽取某个字段将是一件非常痛苦的事情。这种标识法使我们在使用大型结构的过程中更方便了。

##参数化类型

我们曾不止一次地提到列表类型是多态的：列表中的元素可以是任何类型。我们也可以给自定义的类型添加多态性。只要在类型定义中使用类型变量就可以做到这一点。Prelude 中定义了一种叫做 `Maybe` 的类型：它用来表示这样一种值——既可以有值也可能空缺，比如数据库中某行的某字段就可能为空。
```
-- file: ch03/Nullable.hs
data Maybe a = Just a
             | Nothing
```
译注：Maybe，Just，Nothing 都是 Prelude 中已经定义好的类型
这段代码是不能在 ghci 里面执行的，它简单地展示了标准库是怎么定义 Maybe 这种类型的
这里的变量 a 不是普通的变量：它是一个类型变量。它意味着 `Maybe 类型使用另一种类型作为它的参数。从而使得 Maybe 可以作用于任何类型的值。
```
-- file: ch03/Nullable.hs
someBool = Just True
someString = Just "something"
```
和往常一样，我们可以在 ghci 里试着用一下这种类型。
```
ghci> Just 1.5
Just 1.5
ghci> Nothing
Nothing
ghci> :type Just "invisible bike"
Just "invisible bike" :: Maybe [Char]
```
Maybe 是一个多态，或者称作泛型的类型。我们向 Maybe 的类型构造器传入某种类型作为参数，例如 `Maybe Int `或 `Maybe [Bool]`。 如我们所希望的那样，这些都是不同的类型（译注：可能省略了“但是都可以成功传入作为参数”）。

我们可以嵌套使用参数化的类型，但要记得使用括号标识嵌套的顺序，以便 Haskell 编译器知道如何解析这样的表达式。
```
-- file: ch03/Nullable.hs
wrapped = Just (Just "wrapped")
```

##递归类型

列表这种常见的类型就是递归的：即它用自己来定义自己。为了深入了解其中的含义，让我们自己来设计一个与列表相仿的类型。我们将用 Cons 替换 (:) 构造器，用 Nil 替换 [] 构造器。
```
-- file: ch03/ListADT.hs
data List a = Cons a (List a)
            | Nil
              deriving (Show)
```
List a 在 = 符号的左右两侧都有出现，我们可以说该类型的定义引用了它自己。当我们使用 Cons 构造器创建一个值的时候，我们必须提供一个 a 的值作为参数一，以及一个 List a 类型的值作为参数二。接下来我们看一个实例。

我们能创建的 List a 类型的最简单的值就是 Nil。请将上面的代码保存为一个文件，然后打开 ghci 并加载它。
```
ghci> Nil
Nil
```
由于 Nil 是一个 List a 类型（译注：原文是 List 类型，可能是漏写了 a），因此我们可以将它作为 Cons 的第二个参数。
```
ghci> Cons 0 Nil
Cons 0 Nil
```
然后 Cons 0 Nil 也是一个 List a 类型，我们也可以将它作为 Cons 的第二个参数。
```
ghci> Cons 1 it
Cons 1 (Cons 0 Nil)
ghci> Cons 2 it
Cons 2 (Cons 1 (Cons 0 Nil))
ghci> Cons 3 it
Cons 3 (Cons 2 (Cons 1 (Cons 0 Nil)))
```
我们可以一直这样写下去，得到一个很长的 Cons 链，其中每个子链的末位元素都是一个 Nil。

>Tip
List 可以被当作是 list 吗？
让我们来简单的证明一下 List a 类型和内置的 list 类型 [a] 拥有相同的构型。让我们设计一个函数能够接受任何一个 [a] 类型的值作为输入参数，并返回 List a 类型的一个值。
```
-- file: ch03/ListADT.hs
fromList (x:xs) = Cons x (fromList xs)
fromList []     = Nil
```
通过查看上述实现，能清楚的看到它将每个 (:) 替换成 Cons，将每个 [] 替换成 Nil。这样就涵盖了内置 list 类型的全部构造器。因此我们可以说二者是同构的，它们有着相同的构型。
```
ghci> fromList "durian"
Cons 'd' (Cons 'u' (Cons 'r' (Cons 'i' (Cons 'a' (Cons 'n' Nil)))))
ghci> fromList [Just True, Nothing, Just False]
Cons (Just True) (Cons Nothing (Cons (Just False) Nil))
```

练习1：`listADT.hs`
练习2：`Tree.hs`

##引入局部变量

在函数体内部，我们可以在任何地方使用 `let` 表达式引入新的局部变量。请看下面这个简单的函数，它用来检查我们是否可以向顾客出借现金。我们需要确保剩余的保证金不少于 100 元的情况下，才能出借现金，并返回减去出借金额后的余额。
```
-- file: ch03/Lending.hs
lend amount balance = let reserve    = 100
                          newBalance = balance - amount
                      in if balance < reserve
                         then Nothing
                         else Just newBalance
```
这段代码中使用了 `let` 关键字标识一个变量声明区块的开始，用 `in` 关键字标识这个区块的结束。每行引入了一个局部变量。变量名在 = 的左侧，右侧则是该变量所绑定的表达式。

>Note
请特别注意我们的用词：在 let 区块中，变量名被绑定到了一个表达式而不是一个值。由于 Haskell 是一门惰性求值的语言，变量名所对应的表达式一直到被用到时才会求值。在上面的例子里，如果没有满足保证金的要求，就不会计算 newBalance 的值。
当我们在一个 let 区块中定义一个变量时，我们称之为``let`` 范围内的变量。顾名思义即是：我们将这个变量限制在这个 let 区块内。
另外，上面这个例子中对空白和缩进的使用也值得特别注意。在下一节 “The offside rule and white space in an expression” 中我们会着重讲解其中的奥妙。

在 let 区块内定义的变量，既可以在定义区内使用，也可以在紧跟着 in 关键字的表达式中使用。

一般来说，我们将代码中可以使用一个变量名的地方称作这个变量名的**作用域（scope）**。如果我们能使用，则说明在作用域内，反之则说明在作用域外 。如果一个变量名在整个源代码的任意处都可以使用，则说明它位于最顶层的作用域。

###where 从句

还有另一种方法也可以用来引入局部变量：where 从句。where 从句中的定义在其所跟随的主句中有效。下面是和 lend 函数类似的一个例子，不同之处是使用了 where 而不是 let。
```
-- file: ch03/Lending.hs
lend2 amount balance = if amount < reserve * 0.5
                       then Just newBalance
                       else Nothing
    where reserve    = 100
          newBalance = balance - amount
```
尽管刚开始使用 where 从句通常会有异样的感觉，但它对于提升可读性有着巨大的帮助。它使得读者的注意力首先能集中在表达式的一些重要的细节上，而之后再补上支持性的定义。经过一段时间以后，如果再用回那些没有 where 从句的语言，你就会怀念它的存在了。

与 let 表达式一样，where 从句中的空白和缩进也十分重要。 在下一节 “The offside rule and white space in an expression” 中我们会着重讲解其中的奥妙。

###局部函数与全局变量

在 Haskell 的语法里，定义变量和定义函数的方式非常相似。这种相似性也存在于 let 和 where 区块里：定义局部函数就像定义局部变量那样简单。
```
-- file: ch03/LocalFunction.hs
pluralise :: String -> [Int] -> [String]
pluralise word counts = map plural counts
    where plural 0 = "no " ++ word ++ "s"
          plural 1 = "one " ++ word
          plural n = show n ++ " " ++ word ++ "s"
```
我们定义了一个由多个等式构成的局部函数 plural。局部函数可以自由地使用其被封装在内的作用域内的任意变量：在本例中，我们使用了在外部函数 pluralise 中定义的变量 word。在 pluralise 的定义里，`map` 函数（我们将在下一章里再来讲解它的用法）将局部函数 plural 逐一应用于 counts 列表的每个元素。

我们也可以在代码的一开始就定义变量，语法和定义函数是一样的。
```
-- file: ch03/GlobalVariable.hs
itemName = "Weighted Companion Cube"
```

##表达式里的缩进规则和空白字符

Haskell 依据缩进来解析代码块。这种用排版来表达逻辑结构的方式通常被称作缩进规则。在源码文件开始的那一行，首个顶级声明或者定义可以从该行的任意一列开始，Haskell 编译器或解释器将记住这个缩进级别，并且随后出现的所有顶级声明也必须使用相同的缩进。

以下是一个顶级缩进规则的例子。第一个文件 GoodIndent.hs 执行正常。
```
-- file: ch03/GoodIndent.hs
-- 这里是最左侧一列

    -- 顶级声明可以从任一列开始
    firstGoodIndentation = 1

    -- 只要所有后续声明也这么做！
    secondGoodIndentation = 2
```
第二个文件 BadIndent.hs 没有遵守规则，因此也不能正常执行。
```
-- file: ch03/BadIndent.hs
-- 这里是最左侧一列

    -- 第一个声明从第 4 列开始
    firstBadIndentation = 1

-- 第二个声明从第 1 列开始，这样是非法的！
secondBadIndentation = 2
```
紧跟着的（译注：一个或多个）空白行将被视作当前行的延续，比当前行缩进更深的紧跟着的行也是如此。

let 表达式和 where 从句的规则与此类似。一旦 Haskell 编译器或解释器遇到一个 let 或 where 关键字，就会记住接下来第一个标记（token）的缩进位置。然后如果紧跟着的行是空白行或向右缩进更深，则被视作是前一行的延续。而如果其缩进和前一行相同，则被视作是同一区块内的新的一行。
```
-- file: ch03/Indentation.hs
foo = let firstDefinition = blah blah
          -- 只有注释的行被视作空白行
                  continuation blah

          -- 减少缩进，于是下面这行就变成了一行新定义
          secondDefinition = yada yada

                  continuation yada
      in whatever
```
下面的例子演示了如何嵌套使用 let 和 where。
```
-- file: ch03/letwhere.hs
bar = let b = 2
          c = True
      in let a = b
         in (a, c)
```
变量 a 只在内部那个 let 表达式中可见。它对外部那个 let 是不可见的。如果我们在外部使用变量 a 就会得到一个编译错误。缩进为我们和编译器提供了视觉上的标识，让我们可以一眼就看出来作用域中包含哪些东西。
```
-- file: ch03/letwhere.hs
foo = x
    where x = y
            where y = 2
```
于此类似，第一个 where 从句的作用域即是定义 foo 的表达式，而第二个 where 从句的作用域则是第一个 where 从句。

在 let 和 where 从句中妥善地使用缩进能够更好地展现代码的意图。

（后面没怎么看懂）