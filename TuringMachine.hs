{-# LANGUAGE NoMonomorphismRestriction, RankNTypes #-}
import qualified Data.Map as MMap (Map,fromList,keys,elems,insert,lookup)
import Data.Maybe
data Dir = N | L | R 
type Node = (Char,Int,Dir)
type State = MMap.Map Char Node
type Program = [State]
main :: IO()
runMT :: Program -> String -> String
makeInfList :: forall k a. (Num k, Ord k) => [a] -> MMap.Map k a
infToStr :: forall k . (Eq k, Num k) => MMap.Map k Char -> String
makeInfList s = MMap.fromList s'
    where tranform' x s'' | null s'' = []
                          | otherwise = (x,head s''):tranform' (x+1) (tail s'') 
          s' = tranform' 0 s
infToStr m = iterate' (MMap.keys m) (MMap.elems m)
    where iterate' xs' ys'  = case (xs',ys') of
            ([],_) -> []
            (_, b:[]) -> [b]
            (a:xs,c:ys) -> c:lambdas (head xs - a - 1) ++  iterate' xs ys
                where lambdas x | x == 0 = []
                                | otherwise = '_':lambdas (x-1)
runMT prog' str = _runMT (MMap.fromList []:prog') (makeInfList str) 0 1
    where _runMT prog list position curState = let curChar = fromMaybe '_' (MMap.lookup position list)
                                                   (char,next,_dir) = fromMaybe (curChar, 0, N) (MMap.lookup curChar (prog !! curState))
                                                   endOfProg = next == 0
                                                   nlist = MMap.insert position char list
                                                   npos = position + dirToInt _dir
                                                        where dirToInt d = case d of
                                                                L -> (-1) :: Int
                                                                R -> 1
                                                                N -> 0
                                               in if endOfProg then infToStr nlist 
                                                    else _runMT prog nlist npos next

main = putStrLn $ runMT prog "101"
    where prog = [MMap.fromList [('0',('1',1,R)),('1',('0',1,R))]] :: Program

