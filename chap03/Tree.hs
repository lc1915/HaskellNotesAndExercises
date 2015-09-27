-- file: chap03/Tree.hs

data Tree a = Node a (Tree a) (Tree a)
            | Empty
              deriving (Show)

simpleTree = Node "parent" (Node "left child" Empty Empty)
                           (Node "right child" Empty Empty)

-- Exercise 2
{-- data MyTree a = MyNode a (Maybe a) (Maybe a)
                deriving (Show) --}
data MyTree a = MyNode a (Maybe (MyTree a)) (Maybe (MyTree a))
                deriving (Show)
mySimpleTree = MyNode "me" (Just (MyNode "aaa" Nothing Nothing))
                           (Just (MyNode "bbb" Nothing Nothing))
-- 之前的版本：
{-- mySimpleTree = MyNode "me" (MyNode "aaa" Nothing Nothing)
                               (MyNode "bbb" Nothing Nothing) --}
-- 用Maybe的时候一定要记得用Just和Nothing