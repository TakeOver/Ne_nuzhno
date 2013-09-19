-- find index of substring in string
findIndex :: String -> String -> Int
findIndex str sub 
    | str == sub = 1
    | length str <= length sub = -1
    | take (length sub) str == sub = 1
    | otherwise = if idx > 0 then 1 + idx else -1
        where idx = findIndex (drop 1 str) sub 
-- find substring in string and split it (left,sub,right) -> (left,right)
findAndSplit :: String -> String -> Maybe (String,String)
findAndSplit str sub = let idx = findIndex str sub in
    if idx <= 0 then Nothing
                else Just (take (idx - 1) str,drop (idx + length sub - 1) str)
-- find first matched rule and process it.
processRules :: [(String,String,Bool)] -> String -> Maybe (String,Bool)
processRules [] _ = Nothing
processRules rules str = case findAndSplit str sub of 
    Nothing -> processRules (drop 1 rules) str
    Just (left,right) -> Just (left ++ pattern ++ right,not next)
    where (sub,pattern,next) = head rules 
-- main function of NMA
logAndRun :: (t -> String -> IO b) -> t -> String -> IO b
logAndRun f r n = do putStrLn n
                     f r n
runNMA :: [(String,String,Bool)] -> String -> IO String
runNMA rules str = case processRules rules str of
    Nothing -> return str
    Just (newstr,next) -> if next then logAndRun runNMA rules newstr 
                                  else return newstr
-- sugar
(~>),(|~>) :: String -> String -> (String,String,Bool)
(~>) str1 str2 = (str1,str2,False)
(|~>) str1 str2 = (str1,str2,True)
--example
main :: IO()
main = do s <- runNMA rules "||||||||||||||||||||||||||||||" -- res = "|||*|||"
          putStrLn s
    where rules = [ "13" ~>  "3|",
                    "42" ~>  "|4",
                    "3"  ~>  "|",
                    "4"  |~> "|",
                    "||" ~>  "12",
                    "21" ~>  "12",
                    "12" ~>  "3*4"]
