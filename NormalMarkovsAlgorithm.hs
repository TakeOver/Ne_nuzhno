findIndex :: String -> String -> Int
findIndex str sub 
    | str == sub = 1
    | length str <= length sub = -1
    | take (length sub) str == sub = 1
    | otherwise = if idx > 0 then 1 + idx else -1
        where idx = findIndex (drop 1 str) sub 

find :: String -> String -> Maybe (String,String)
find str sub = let idx = findIndex str sub in
    if idx <= 0 then Nothing
                else Just (take (idx - 1) str,drop (idx + length sub - 1) str)

doRule :: [(String,String,Bool)] -> String -> Maybe (String,Bool)
doRule [] _ = Nothing
doRule rules str = case find str sub of 
    Nothing -> doRule (drop 1 rules) str
    Just (left,right) -> Just (left ++ pattern ++ right,not next)
    where (sub,pattern,next) = head rules 

runNMA :: [(String,String,Bool)] -> String -> String
runNMA rules str = case doRule rules str of
    Nothing -> str
    Just (newstr,next) -> if next then runNMA rules newstr 
                                  else newstr

(~>),(!~>) :: String -> String -> (String,String,Bool)
(~>) str1 str2 = (str1,str2,False)
(!~>) str1 str2 = (str1,str2,True)

--example
main :: IO()
main = putStrLn $ runNMA rules "aabcbabcc" -- res = "123ebqwec"
    where rules = [ "abc" ~> "qwe",
                    "qw" !~> "123"]
