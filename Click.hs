module Click where

import Sound.Tidal.Context
import Sound.Tidal.OscStream
import Sound.OSC.FD
import Sound.OSC.Datum
import qualified System.Hardware.Serialport as SP
import Control.Monad
import qualified Data.ByteString.Char8 as B
-- import Data.Colour.SRGB
-- import Data.Colour.Names
import Control.Concurrent.MVar
import GHC.Float

fps = 100

click :: Shape
click = Shape {params = [n_p],
               cpsStamp = True,
               latency = 0.4
              }
clickSlang = OscSlang {
  path = "/click",
  timestamp = NoStamp,
  namedParams = False,
  preamble = []
}
  
clickBackend = do s <- makeConnection "127.0.0.1" 9099 clickSlang
                  return $ Backend s (\_ _ _ -> return ())

clickServer = do s <- udpServer "127.0.0.1" 9099
                 output <- SP.openSerial "/dev/ttyUSB0" (SP.defaultSerialSettings {SP.commSpeed = SP.CS115200})
                 clickLoop s output

                 
clickLoop s output = do m <- recvMessage s
                        act m output
                        clickLoop s output
                           
act (Just (Message "/click" [Float cps', Float n])) output = sendClick output (floor $ (n :: Float))

act m output = do putStrLn $ "Unknown message: " ++ show m
                  return ()
                  
clickStream = do backend <- clickBackend
                 stream backend click

sendClick output n = do SP.send output $ B.pack $ show n ++ "c\r"
                        putStrLn $ "send: " ++ (show n)
                        return ()


