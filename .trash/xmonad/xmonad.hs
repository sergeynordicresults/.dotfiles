--xmonad.hs: Configuration file for xmonad
--Imports
--Core
import qualified Data.Map                     as M
import           System.Exit                  (exitSuccess)
import           System.IO                    (hPutStrLn)
import           XMonad
import qualified XMonad.StackSet              as W

--Util
import           XMonad.Util.NamedScratchpad  (NamedScratchpad (NS),
                                               customFloating,
                                               namedScratchpadAction,
                                               namedScratchpadManageHook)
import           XMonad.Util.Run              (runInTerm, safeSpawn, spawnPipe,
                                               unsafeSpawn)
import           XMonad.Util.SpawnOnce

--Hooks
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.FloatNext       (floatNextHook, toggleFloatAllNew,
                                               toggleFloatNext)
import           XMonad.Hooks.InsertPosition
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.Place           (placeHook, smart, withGaps)

import           XMonad.Actions.CopyWindow    (kill1)

--Actions
import           XMonad.Actions.Promote
import           XMonad.Actions.UpdatePointer

import           XMonad.Layout.Gaps
import           XMonad.Layout.NoBorders

--Layouts
import           XMonad.Layout.Spacing        (spacing)

--Constants
myModMask = mod4Mask

myTerm = "urxvt"

myBackgroundColor = "#1f1f2c"

myForegroundColor = "#c7c9cb"

myFocusedColor = "#6A98DB"

myBorderWidth = 4

--Scratchpads
myScratchpads =
  [ NS
      "music"
      (myTerm ++ " -name music -e ncmpcpp")
      (resource =? "music")
      myPosition
  , NS
      "torrent"
      (myTerm ++ " -name torrent -e transmission-remote-cli")
      (resource =? "torrent")
      myPosition
  , NS
      "wcalc"
      (myTerm ++ " -name wcalc -e wcalc")
      (resource =? "wcalc")
      myPosition
  ]
  where
    myPosition = customFloating $ W.RationalRect (1 / 3) (1 / 3) (1 / 3) (1 / 3)

--Keybindings
myKeys conf@XConfig {XMonad.modMask = modMask} =
  M.fromList $
  [ ((modMask .|. shiftMask, xK_q), io exitSuccess)
  , ((modMask, xK_q), kill1)
  , ((modMask, xK_BackSpace), promote)
  , ((modMask, xK_l), sendMessage Expand)
  , ((modMask, xK_h), sendMessage Shrink)
  , ((modMask, xK_f), sendMessage NextLayout)
  , ((modMask, xK_comma), sendMessage (IncMasterN 1))
  , ((modMask, xK_period), sendMessage (IncMasterN (-1)))
  , ((modMask, xK_j), windows W.focusDown)
  , ((modMask, xK_k), windows W.focusUp)
  , ((modMask, xK_m), windows W.focusMaster)
  , ((modMask .|. shiftMask, xK_j), windows W.swapDown)
  , ((modMask .|. shiftMask, xK_k), windows W.swapUp)
  , ((modMask, xK_Return), spawn myTerm)
  , ((modMask, xK_w), spawn "firefox")
  , ((modMask, xK_space), spawn "bashrun")
  , ( (modMask, xK_s)
    , spawn
        "notify-send \"Started recording\" \"Mod+D to stop\"; ffmpeg -y -f x11grab -video_size 1600x900 -i $DISPLAY -c:v ffvhuff -c:a none ~/Pictures/tmp/screencast.mkv")
  , ( (modMask, xK_d)
    , spawn
        "killall -9 ffmpeg; notify-send \"Stopped recording\" \"Encoding to webm\"; ffmpeg -y -i ~/Pictures/tmp/screencast.mkv -c:v libvpx -c:a none -b:v 2000k -s 1067x600 ~/Pictures/tmp/screencast.webm; rm ~/Pictures/tmp/screencast.mkv; notify-send \"Done encoding\"")
  , ((0, 0x1008ff1d), namedScratchpadAction myScratchpads "wcalc")
  , ((modMask, xK_b), namedScratchpadAction myScratchpads "torrent")
  , ((modMask, xK_n), namedScratchpadAction myScratchpads "music")
  , ((modMask, xK_t), withFocused $ windows . W.sink)
  , ((modMask, xK_a), spawn "scrotTek; notify-send \"Screen was scrotted\"")
  , ((0, 0x1008ff14), spawn "ncmpcpp toggle")
  , ((0, 0x1008ff11), spawn "amixer set Master 5%- unmute")
  , ((0, 0x1008ff13), spawn "amixer set Master 5%+ unmute")
  ] ++
  [ ((m .|. modMask, k), windows $ f i)
  | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
  , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ]

--Hooks
--A list of strings: each string is the name of a workspace
myWorkspaces = [" 一", "二", "三", "四"]

--A function which defines rules on how we output to the bar
myLogHook h =
  dynamicLogWithPP $
  defaultPP
  { ppOutput = hPutStrLn h
  , ppCurrent = \s -> " ● "
  , ppHidden = noScratchPad
  , ppHiddenNoWindows = noScratchPad
  , ppOrder = \(ws:l:t:_) -> [ws]
  }
  where
    noScratchPad ws =
      if ws == "NSP"
        then ""
        else " ○ "

--Manage hook: float some windows by default
myManageHook =
  placeHook (smart (0.5, 0.5)) <+>
  insertPosition End Newer <+>
  namedScratchpadManageHook myScratchpads <+>
  (composeAll . concat $
   [ [isFullscreen --> (doF W.focusDown <+> doFullFloat)]
   , [className =? "MPlayer" --> doFloat]
   , [className =? "mpv" --> doFloat]
   , [className =? "qemu-system-i3i86" --> doFloat]
   , [resource =? "bashrun" --> doFloat]
   , [resource =? "Steam" --> doFloat]
   , [className =? "feh" --> doFloat]
   , [isDialog --> doFloat]
   ]) <+>
  manageDocks

--Some layouts
myLayoutHook =
  gaps [(U, 50), (L, 30), (R, 30)] $
  spacing 30 $ lessBorders OnlyFloat $ tiled ||| Full
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    ratio = 1 / 2
    delta = 3 / 100

--Commands to run on startup
myStartupHook = do
  spawnOnce "setxkbmap gb"
  spawnOnce "sh ~/.fehbg &"
  spawnOnce "mpd &"
  spawnOnce "xsetroot -cursor_name left_ptr &"
  spawnOnce "transmission-daemon &"
  spawnOnce "compton -r4 -l-6 -t-5 -o.99 -e 0.7 -b &"

--Main: Run the bar and pass our config to xmonad
main = do
  bar <- spawnPipe "~/.bin/barScript.py | bar"
  xmonad $
    defaultConfig
    { modMask = myModMask
    , workspaces = myWorkspaces
    , logHook = myLogHook bar >> updatePointer (Relative 0.5 0.5)
    , layoutHook = myLayoutHook
    , manageHook = myManageHook
    , startupHook = myStartupHook
    , keys = myKeys
    , normalBorderColor = myForegroundColor
    , focusedBorderColor = myFocusedColor
    , borderWidth = myBorderWidth
    }
