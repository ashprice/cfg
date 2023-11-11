import System.Exit
import System.IO (hClose, hPutStr)
import qualified Data.Map as M
import XMonad
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.NoBorders
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

--import XMonad.Prompt.ConfirmPrompt

myFont :: String
myFont = "xft:Iosefka Custom:size 24:antialias=true:hinting=true"

myBrowser :: String
myBrowser = "firefox"

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myWorkSpaces :: [String]
myWorkSpaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

main :: IO ()
main = xmonad $ ewmhFullscreen $ ewmh $ myConfig

myConfig =
  def
    { modMask = myModMask,
      terminal = myTerminal,
      borderWidth = myBorderWidth,
      startupHook = myStartupHook,
      manageHook = myManageHook,
      layoutHook = myLayout,
      normalBorderColor = "grey20",
      focusedBorderColor = "white"
    }
    `additionalKeysP` [ ("M-d", spawn "dmenu_run -fn 'Noto Sans Mono-24'"),
                        ("M-m", spawn "wezterm start --always-new-process ncmpcpp"),
                        ("M-w", spawn ("firefox" ++ " >/dev/null 2>&1")),
                        ("M--", spawn "pamixer allow-boost -d 5"),
                        ("M-=", spawn "pamixer allow-boost -i 5"),
                        ("M-S--", spawn "pamixer allow-boost -d 15"),
                        ("M-S-=", spawn "pamixer allow-boost -i 15"),
                        ("M-p", spawn "mpc toggle"),
                        ("M-,", spawn "mpc prev"),
                        ("M-.", spawn "mpc next"),
                        ("M-S-,", spawn "mpc seek 0%"),
                        ("M-S-.", spawn "mpc repeat"),
                        ("M-<Return>", spawn "wezterm"),
                        ("M-S-<Return>", namedScratchpadAction myScratchPads "terminal"),
                        ("M-c", kill1),
                        ("M-'", namedScratchpadAction myScratchPads "calculator"),
                        ("M-f", sendMessage (Toggle "Full"))
                      ]

myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "wezterm"

myBorderWidth :: Dimension
myBorderWidth = 1

myEditor :: String
myEditor = "hx"

-- myEditor = "nvim"

--myKeys :: [(String, X ())]
--myKeys =
--  ("M-S-q", confirmPrompt defaultXPConfig "exit" $ io exitSuccess)

myStartupHook :: X ()
myStartupHook = do
  --  return () >> checkKeymap myConfig
  spawnOnce "xrandr --dpi 91"
  spawnOnce "xset r rate 300 50"
  spawnOnce "xsetroot -cursor_name left_ptr"
  spawnOnce "xrdb -merge ~/.Xresources &" -- just for redundancy
  spawnOnce "unclutter &"
  spawnOnce "~/.local/bin/tools/chngbg &"
  spawnOnce "sxhkd &"
  spawnOnce "setxkbmap gb &"
  spawnOnce "picom &"
  spawnOnce "ibus-daemon -drx &"

myManageHook :: ManageHook
myManageHook =
  composeAll
    [ className =? "Gimp" --> doFloat,
      isDialog --> doFloat,
      role =? "page-info" --> doFloat,
      role =? "pop-up" --> doFloat
    ]
  where
    role = stringProperty "WM_WINDOW_ROLE"

--layoutHook :: LayoutHook
--layoutHook = spacingRaw False (Border 10 0 10 0) True (Border 0 10 0 10) True $ Tall (1 (3/100) (1/2)) ||| Full

myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ NS "terminal" spawnTerm findTerm manageTerm,
    NS "calculator" spawnCalc findCalc manageCalc,
    NS "ncmpcpp" "ncmpcpp" (className =? "ncmcpp") defaultFloating
  ]
  where
    spawnTerm = myTerminal ++ " start --class scratchpad"
    findTerm = className =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w
    spawnCalc = "wezterm start --class calc qalc"
    findCalc = className =? "calc"
    manageCalc = customFloating $ W.RationalRect l t w h
      where
        h = 0.5
        w = 0.4
        t = 0.75 - h
        l = 0.70 - w

--toggleFull = withFocused (\windowID -> do
--  { floats <- gets (W.floating . windowset);
--    if windowID `M.member` floats
--    then withFocused $ windows . W.sink
--    else withFocused $ windows . (flip W.float $ W.RationalRect 0 0 1 1) })

myLayout = smartBorders 
  $ toggleLayouts (noBorders Full)
  $ smartSpacing 4
  $ Tall 1 (3/100) (1/2) ||| Mirror (Tall 1 (3/100) (1/2))

toggleFullScreen :: X ()
toggleFullScreen =
  withWindowSet $ \ws ->
  withFocused $ \w -> do
    let fullRect = W.RationalRect 0 0 1 1
    let isFullFloat = w `M.lookup` W.floating ws == Just fullRect
    windows $ if isFullFloat then W.sink w else W.float w fullRect
