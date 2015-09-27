-- file: chap03/Lending.hs
-- 这段代码中使用了 let 关键字标识一个变量声明区块的开始，用 in 关键字标识这个区块的结束。
-- 每行引入了一个局部变量。变量名在 = 的左侧，右侧则是该变量所绑定的表达式。
lend amount balance = let reserve    = 100
                          newBalance = balance - amount
                      in if balance < reserve
                         then Nothing
                         else Just newBalance