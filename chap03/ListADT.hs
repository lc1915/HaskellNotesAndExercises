-- file: chap03/ListADT.hs

-- List: 类型构造器 Cons/Nil: 值构造器
data List a = Cons a (List a)
            | Nil
              deriving (Show)

-- 简单的证明一下 List a 类型和内置的 list 类型 [a] 拥有相同的构型
fromList (x:xs) = Cons x (fromList xs)
fromList []     = Nil

-- 自己写的错的
{-- toList a = if a not Nil
           then 1:(toList a)
           else [] --}

-- Exercise 1
toList (Cons a as) = a : toList as
toList Nil         = []