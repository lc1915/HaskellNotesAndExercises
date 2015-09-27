-- file: chap03/MySecond.hs

safeSecond :: [a] -> Maybe a

safeSecond [] = Nothing
safeSecond xs = if null (tail xs)
                then Nothing
                else Just (head (tail xs))


-- 我们还可以使用模式匹配继续增强这个函数的可读性。
tidySecond :: [a] -> Maybe a

tidySecond (_:x:_) = Just x
tidySecond _       = Nothing
-- (_:x:_) 相当于 (_:(x:_))
-- 假设是[1,2]，进行第一个模式匹配，(1:(x:_)) -> (1:(2:[]))，匹配成功。
-- 如果是[1]或者[]就不能成功模式匹配，则匹配第二个模式。