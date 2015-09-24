doubleMe x = x + x
--doubleUs x y = x * 2 + y * 2
doubleUs x y = doubleMe x + doubleMe y

doubleSmallNumber x = if x > 100
    then x
    else x * 2

-- 注意函数名最后的那个单引号，它没有任何特殊含义，只是一个函数名的合法字符罢了。通常，我们使用单引号来区分一个稍经修改但差别不大的函数。
doubleSmallNumber' x = (if x > 100 then x else x * 2) + 1

{-
1. 首字母大写的函数是不允许的
2. 这个函数并没有任何参数。
没有参数的函数通常被称作“定义”（或者“名字”），一旦定义，conanO'Brien就与字符串"It's a-me, Conan O'Brien!"完全等价，且它的值不可以修改。
-}
conaon'Brien = "It's a-me, Conan O'Brien!"

lostNumbers = [4,5,15,16,23,48]