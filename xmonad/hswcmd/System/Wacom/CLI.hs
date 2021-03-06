
module System.Wacom.CLI where

import System.Wacom.Types
import System.Wacom.Profiles

-- | Supported commands
data Command =
    Quit              -- ^ quit
  | SetProfile String -- ^ set name
  | GetCurrentProfile -- ^ get
  | SetRingMode Int   -- ^ ring 1
  | ToggleRingMode    -- ^ ring +
  | GetRingMode       -- ^ ring
  | Map Int           -- ^ map 0
  | GetMap            -- ^ map
  deriving (Eq, Show)

-- | Implementation of command-line utility to control the daemon.
client :: WacomHandle -> IO ()
client wh = do
    cmd <- readCommand
    rs <- run cmd
    case rs of
      Left err -> putStrLn $ "Error: " ++ err
      Right r -> putStrLn $ "Done: " ++ r
    case cmd of
      Quit -> putStrLn "Client quit"
      _ -> client wh
  where
    readCommand :: IO Command
    readCommand = do
      putStr "client> "
      str <- getLine
      case words str of
        ["quit"] -> return Quit
        ["set",profile] -> return $ SetProfile profile
        ["get"] -> return GetCurrentProfile
        ["ring"] -> return GetRingMode
        ["ring","+"] -> return ToggleRingMode
        ["ring",s] -> return $ SetRingMode (read s)
        ["map"] -> return GetMap
        ["map",s] -> return $ Map (read s)
        _ -> do
          putStrLn "Unknown command"
          readCommand

    run :: Command -> IO (Result String)
    run Quit = return $ Right "Quit"
    run (SetProfile name) = setProfile wh name
    run GetCurrentProfile = getProfileName wh
    run GetRingMode = getRingMode wh
    run (SetRingMode idx) = setRingMode wh idx
    run ToggleRingMode = toggleRingMode wh
    run GetMap = getMapArea wh
    run (Map idx) = setMapArea wh idx

