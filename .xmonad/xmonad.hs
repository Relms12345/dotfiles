-- Imports
import XMonad
import Data.Monoid
import System.Exit
import XMonad.Util.SpawnOnce
import Graphics.X11.ExtraTypes.XF86
import XMonad.Hooks.EwmhDesktops
import Control.Monad
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Util.Run
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- Just some variables
myTerminal = "kitty"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth = 2

myModMask = mod4Mask

myNormalBorderColor = "#dddddd"

myFocusedBorderColor = "#4172bf"

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
    doubleLts '<' = "<<"
    doubleLts x   = [x]


myWorkspaces = ["dev","www","chat","mus","virt","game","rec","edit","9"]
myClickableWorkspaces :: [String]
myClickableWorkspaces = clickable . (map xmobarEscape) $ ["dev","www","chat","mus","virt","game","rec","edit","9"]
  where 
    clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" | (i,ws) <- zip [1..9] l,let n = i ]
------------------------------------------------------------------------
-- Key bindings
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [
      -- launch a terminal
      ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

      -- launch rofi
    , ((modm, xK_p), spawn "rofi -no-lazy-grab -show drun -modi run,drun,window -theme ~/.config/rofi/launcher/style -drun-icon-theme Adwaita")

      -- close focused window
    , ((modm .|. shiftMask, xK_c), kill)

      -- Rotate through the available layout algorithms
    , ((modm, xK_space), sendMessage NextLayout)

      --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

      -- Resize viewed windows to the correct size
    , ((modm, xK_n), refresh)

      -- Move focus to the next window
    , ((modm, xK_Tab), windows W.focusDown)

      -- Move focus to the next window
    , ((modm, xK_j), windows W.focusDown)

      -- Move focus to the previous window
    , ((modm, xK_k), windows W.focusUp)

      -- Move focus to the master window
    , ((modm, xK_m), windows W.focusMaster)

      -- Swap the focused window and the master window
    , ((modm, xK_Return), windows W.swapMaster)

      -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j), windows W.swapDown)

      -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k), windows W.swapUp)

      -- Shrink the master area
    , ((modm, xK_h), sendMessage Shrink)

      -- Expand the master area
    , ((modm, xK_l), sendMessage Expand)

      -- Push window back into tiling
    , ((modm, xK_t), withFocused $ windows . W.sink)

      -- Increment the number of windows in the master area
    , ((modm, xK_comma), sendMessage (IncMasterN 1))

      -- Deincrement the number of windows in the master area
    , ((modm, xK_period), sendMessage (IncMasterN (-1)))

      -- Show powermenu
    , ((modm .|. shiftMask, xK_q), spawn "~/bin/powermenu.sh")

      -- Restart xmonad
    , ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart")

      -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))

      -- Take Screenshot of screen
    , ((noModMask, xK_Print), spawn "flameshot full -p ~/Pictures")
    ]
    ++
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [
      ((m .|. modm, k), windows $ f i) | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
    , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ]
------------------------------------------------------------------------
-- Mouse bindings
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
  [ 
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modm, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
  , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
  , ((modm, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))
  ]
------------------------------------------------------------------------
-- Layouts
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100
------------------------------------------------------------------------
-- Window rules
myManageHook = composeAll
  [ 
    className =? "MPlayer"        --> doFloat
  , className =? "Gimp"           --> doFloat
  , resource  =? "desktop_window" --> doIgnore
  , resource  =? "kdesktop"       --> doIgnore 
  ]
------------------------------------------------------------------------
-- Event handling
myEventHook = mempty
------------------------------------------------------------------------
-- Status bars and logging
myLogHook = return ()
------------------------------------------------------------------------
-- Startup hook
myStartupHook = do
  -- spawnOnce "plank &"
  spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &"
  spawnOnce "dunst &"
  -- spawnOnce "picom --experimental-backend &"
  spawnOnce "xscreensaver -no-splash"
  spawnOnce "trayer --edge top --align right --widthtype request --padding 3 --SetDockType true --SetPartialStrut true --expand true --monitor 0 --transparent true --alpha 0 --tint 0x282c34 --height 24 --iconspacing 4 &"
  spawnOnce "pasystray &"
  spawnOnce "nm-applet &"
  --spawnOnce "cbatticon --icon-type symbolic --low-level 20 --critical-level 10 &"
  spawnOnce "conky &"
  spawnOnce "kdeconnect-indicator &"
  spawnOnce "feh --bg-fill --randomize /usr/share/backgrounds/* &"
  setWMName "LG3D"
------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.
main = do
  xmproc <- spawnPipe "xmobar /home/relms/.config/xmobar/xmobarrc"
  xmonad $ docks $ ewmhFullscreen $ ewmh def {
  -- simple stuff
  terminal           = myTerminal,
  focusFollowsMouse  = myFocusFollowsMouse,
  clickJustFocuses   = myClickJustFocuses,
  borderWidth        = myBorderWidth,
  modMask            = myModMask,
  workspaces         = myClickableWorkspaces,
  normalBorderColor  = myNormalBorderColor,
  focusedBorderColor = myFocusedBorderColor,

  -- key bindings
  keys               = myKeys,
  mouseBindings      = myMouseBindings,

  -- hooks, layouts
  layoutHook         = gaps [(L,0), (R,0), (U,0), (D,0)] $ spacingRaw True (Border 0 0 0 0) True (Border 0 0 0 0) True $ smartBorders $ myLayout,
  manageHook         = myManageHook,
  handleEventHook    = myEventHook,
  startupHook        = myStartupHook,
  logHook            = myLogHook <+> dynamicLogWithPP xmobarPP { 
    ppOutput = \x -> hPutStrLn xmproc x
  , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]"
  , ppVisible = xmobarColor "#98be65" ""
  , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""
  , ppHiddenNoWindows = xmobarColor "#c792ea" ""
  , ppTitle = xmobarColor "#b3afc2" "" . shorten 60
  , ppSep =  "<fc=#666666> <fn=1>|</fn> </fc>"
  , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"
  , ppOrder  = \(ws:l:t:ex) -> [ws]++ex++[t]
  }
}
------------------------------------------------------------------------
-- Help Menu
-- I'll update this once i finalize my keybindings
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
  "",
  "-- launching and killing programs",
  "mod-Shift-Enter  Launch xterminal",
  "mod-p            Launch dmenu",
  "mod-Shift-p      Launch gmrun",
  "mod-Shift-c      Close/kill the focused window",
  "mod-Space        Rotate through the available layout algorithms",
  "mod-Shift-Space  Reset the layouts on the current workSpace to default",
  "mod-n            Resize/refresh viewed windows to the correct size",
  "",
  "-- move focus up or down the window stack",
  "mod-Tab        Move focus to the next window",
  "mod-Shift-Tab  Move focus to the previous window",
  "mod-j          Move focus to the next window",
  "mod-k          Move focus to the previous window",
  "mod-m          Move focus to the master window",
  "",
  "-- modifying the window order",
  "mod-Return   Swap the focused window and the master window",
  "mod-Shift-j  Swap the focused window with the next window",
  "mod-Shift-k  Swap the focused window with the previous window",
  "",
  "-- resizing the master/slave ratio",
  "mod-h  Shrink the master area",
  "mod-l  Expand the master area",
  "",
  "-- floating layer support",
  "mod-t  Push window back into tiling; unfloat and re-tile it",
  "",
  "-- increase or decrease number of windows in the master area",
  "mod-comma  (mod-,)   Increment the number of windows in the master area",
  "mod-period (mod-.)   Deincrement the number of windows in the master area",
  "",
  "-- quit, or restart",
  "mod-Shift-q  Quit xmonad",
  "mod-q        Restart xmonad",
  "mod-[1..9]   Switch to workSpace N",
  "",
  "-- Workspaces & screens",
  "mod-Shift-[1..9]   Move client to workspace N",
  "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
  "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
  "",
  "-- Mouse bindings: default actions bound to mouse events",
  "mod-button1  Set the window to floating mode and move by dragging",
  "mod-button2  Raise the window to the top of the stack",
  "mod-button3  Set the window to floating mode and resize by dragging"]
