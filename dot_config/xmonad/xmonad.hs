  -- Base
import           System.Directory
import           System.Exit                         (exitSuccess)
import           System.IO                           (hPutStrLn)
import           XMonad
import qualified XMonad.StackSet                     as W

    -- Actions
import           XMonad.Actions.CopyWindow           (kill1)
import           XMonad.Actions.CycleWS              (WSType (..), moveTo,
                                                      nextScreen, nextWS,
                                                      prevScreen, prevWS,
                                                      shiftNextScreen,
                                                      shiftPrevScreen, shiftTo,
                                                      toggleWS)
import           XMonad.Actions.GridSelect
import           XMonad.Actions.MouseResize
import           XMonad.Actions.Promote
import           XMonad.Actions.RotSlaves            (rotAllDown, rotSlavesDown)
import qualified XMonad.Actions.Search               as S
import qualified XMonad.Actions.TreeSelect           as TS
import           XMonad.Actions.UpdatePointer
import           XMonad.Actions.WindowGo             (runOrRaise)
import           XMonad.Actions.WithAll              (killAll, sinkAll)

    -- Data
import           Data.Char                           (isSpace, toUpper)
import qualified Data.Map                            as M
import           Data.Maybe                          (fromJust, isJust)
import           Data.Monoid
import           Data.Tree

    -- Hooks
import           XMonad.Hooks.DynamicLog             (PP (..), dynamicLogWithPP,
                                                      shorten, wrap,
                                                      xmobarColor, xmobarPP)
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.FadeInactive
import           XMonad.Hooks.ManageDocks            (ToggleStruts (..),
                                                      avoidStruts,
                                                      docksEventHook,
                                                      manageDocks)
import           XMonad.Hooks.ManageHelpers          (doFullFloat, isFullscreen)
import           XMonad.Hooks.ServerMode
import           XMonad.Hooks.SetWMName
import           XMonad.Hooks.UrgencyHook
import           XMonad.Hooks.WorkspaceHistory

    -- Layouts
import           XMonad.Layout.GridVariants          (Grid (Grid))
import           XMonad.Layout.ResizableTile
import           XMonad.Layout.SimplestFloat
import           XMonad.Layout.Spiral
import           XMonad.Layout.Tabbed
import           XMonad.Layout.ThreeColumns

    -- Layouts modifiers
import           XMonad.Layout.LayoutModifier
import           XMonad.Layout.LimitWindows          (decreaseLimit,
                                                      increaseLimit,
                                                      limitWindows)
import           XMonad.Layout.Magnifier
import           XMonad.Layout.MultiToggle           (EOT (EOT), mkToggle,
                                                      single, (??))
import qualified XMonad.Layout.MultiToggle           as MT (Toggle (..))
import           XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import           XMonad.Layout.NoBorders
import           XMonad.Layout.Renamed
import           XMonad.Layout.ShowWName
import           XMonad.Layout.Simplest
import           XMonad.Layout.Spacing
import           XMonad.Layout.SubLayouts
import qualified XMonad.Layout.ToggleLayouts         as T (ToggleLayout (Toggle),
                                                           toggleLayouts)
import           XMonad.Layout.WindowArranger        (WindowArrangerMsg (..),
                                                      windowArrange)
import           XMonad.Layout.WindowNavigation

    -- Prompt
import           XMonad.Prompt
import           XMonad.Prompt.FuzzyMatch
import           XMonad.Prompt.Input
import           XMonad.Prompt.Man
import           XMonad.Prompt.Pass
import           XMonad.Prompt.Shell
import           XMonad.Prompt.Ssh
import           XMonad.Prompt.Unicode
import           XMonad.Prompt.XMonad

import           Control.Arrow                       (first)


-- Imports for Polybar --
import qualified Codec.Binary.UTF8.String            as UTF8
import qualified DBus                                as D
import qualified DBus.Client                         as D
import           XMonad.Hooks.DynamicLog



   -- Utilities
import           XMonad.Util.EZConfig                (additionalKeysP)
import           XMonad.Util.NamedScratchpad
import           XMonad.Util.Run                     (runProcessWithInput,
                                                      safeSpawn, spawnPipe)
import           XMonad.Util.SpawnOnce





-- ------------------------------------------------------------------------
-- -- Polybar settings (needs DBus client).
-- --
-- mkDbusClient :: IO D.Client
-- mkDbusClient = do
--   dbus <- D.connectSession
--   D.requestName dbus (D.busName_ "org.xmonad.log") opts
--   return dbus
--  where
--   opts = [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]
--
-- -- Emit a DBus signal on log updates
-- dbusOutput :: D.Client -> String -> IO ()
-- dbusOutput dbus str =
--   let opath  = D.objectPath_ "/org/xmonad/Log"
--       iname  = D.interfaceName_ "org.xmonad.Log"
--       mname  = D.memberName_ "Update"
--       signal = D.signal opath iname mname
--       body   = [D.toVariant $ UTF8.decodeString str]
--   in  D.emit dbus $ signal { D.signalBody = body }
--
-- polybarHook :: D.Client -> PP
-- polybarHook dbus =
--   let wrapper c s | s /= "NSP" = wrap ("%{F" <> c <> "} ") " %{F-}" s
--                   | otherwise  = mempty
--       blue   = "#2E9AFE"
--       gray   = "#7F7F7F"
--       orange = "#ea4300"
--       purple = "#9058c7"
--       red    = "#722222"
--   in  def { ppOutput          = dbusOutput dbus
--           , ppCurrent         = wrapper blue
--           , ppVisible         = wrapper gray
--           , ppUrgent          = wrapper red --orange
--           , ppHidden          = wrapper gray
--           , ppHiddenNoWindows = \_ -> "" --wrapper red
--           , ppTitle           = wrapper purple . shorten 90
--           }
--
-- myPolybarLogHook dbus =  dynamicLogWithPP (polybarHook dbus)



myLogHook :: X ()
myLogHook = fadeInactiveLogHook 0.95 -- 0.9








myFont :: String
myFont = "xft:Lato:bold:size=9:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask       -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "/usr/bin/terminal"   -- Sets default terminal

myBorderWidth :: Dimension
myBorderWidth = 1          -- Sets border width for windows
myNormColor :: String
myNormColor   = "#080808"  -- Border color of normal windows
myFocusColor :: String
myFocusColor  = "#ebdbb2"  -- Border color of focused windows

altMask :: KeyMask
altMask = mod1Mask         -- Setting this for use in xprompts

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
--  spawnOnce "~/.config/polybar/launch.sh &"
--  spawnOnce "nitrogen --restore &"
  spawnOnce "autorandr -c &"
--   spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x080808  --height 22 &"
  setWMName "LG3D"

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "mocp" spawnMocp findMocp manageMocp
                ]
  where
    spawnTerm  = myTerminal ++ " -n scratchpad"
    findTerm   = resource =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnMocp  = myTerminal ++ " -n mocp 'mocp'"
    findMocp   = resource =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 2
           $ ResizableTall 1 (2/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 2
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
threeCol = renamed [Replace "threeCol"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 11
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 11
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#ebdbb2"
                 , inactiveColor       = "#080808"
                 , activeBorderColor   = "#ebdbb2"
                 , inactiveBorderColor = "#080808"
                 , activeTextColor     = "#080808"
                 , inactiveTextColor   = "#ebdbb2"
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Font Awesome:bold:size=60"
    , swn_fade              = 0.2
    , swn_bgcolor           = "#080808"
    , swn_color             = "#ebdbb2"
    }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     noBorders tabs
                                 ||| tall
                                 ||| noBorders monocle
                                 ||| grid
                                 ||| floats
                                 ||| threeCol
                                 ||| threeRow

--myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 ", "0"]
--myWorkspaces = ["", "", "", "", "", ",", ",", "", "", ""]
--myWorkspaces = zipWith (\x y -> show x ++ y) [1..] ["\61612", "\61728", "\61729", "\61897", "\61717", "\61723", "\61574", "\61477", "\61451", "\61459"]
myWorkspaces = ["\61612", "\61728", "\61729", "\61897", "\61717", "\61723", "\61574", "\61477", "\61451", "\61459"]
myWorkspaceIndices = M.fromList $ zip myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces, and the names would very long if using clickable workspaces.
     [ title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 1 )
     , className =? "mpv"     --> doShift ( myWorkspaces !! 7 )
     , className =? "Gimp"    --> doShift ( myWorkspaces !! 8 )
     , className =? "Gimp"    --> doFloat
     , title =? "Oracle VM VirtualBox Manager"     --> doFloat
     , className =? "VirtualBox Manager" --> doShift  ( myWorkspaces !! 4 )
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     ] <+> namedScratchpadManageHook myScratchPads



myKeys :: [(String, X ())]
myKeys =
    -- Xmonad

        [ ("M-S-r", spawn "xmonad --recompile && xmonad  --restart")   -- Restarts xmonad
        , ("M-S-e", spawn "powermenu")             -- Quits xmonad

    -- Launcher
        , ("M-d", spawn "rofi -show") -- Rofi
        , ("M-x", spawn "rofi -show run") -- Rofi

    -- Useful programs to have a keybinding for launch
        , ("M-<Return>", spawn myTerminal)
        , ("M-c", spawn "clipmenu")

    -- Kill windows
        , ("M-S-q", kill1)     -- Kill the currently focused client
        , ("M-S-C-q", killAll)   -- Kill all windows on current workspace
        , ("M-S-C-x", spawn "xkill")     -- Kill the currently focused client

    -- Workspaces
        , ("M-[", prevScreen)  -- Switch focus to next monitor
        , ("M-S-[", shiftPrevScreen)  -- Switch focus to next monitor
        , ("M-]", nextScreen)  -- Switch focus to prev monitor
        , ("M-S-]", shiftNextScreen)  -- Switch focus to prev monitor
        , ("M-S-h", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to prev ws
        , ("M-S-<Left>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to prev ws
        , ("M-S-l", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next ws
        , ("M-S-<Right>", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next ws

    -- Floating windows
        , ("M-f", sendMessage (T.Toggle "floats")) -- Toggles my 'floats' layout
        , ("M-t", withFocused $ windows . W.sink)  -- Push floating window back to tile
        , ("M-S-t", sinkAll)                       -- Push ALL floating windows to tile

    -- Increase/decrease spacing (gaps)
        , ("M--", decWindowSpacing 4)           -- Decrease window spacing
        , ("M-=", incWindowSpacing 4)           -- Increase window spacing
        , ("M-S--", decScreenSpacing 4)         -- Decrease screen spacing
        , ("M-S-=", incScreenSpacing 4)         -- Increase screen spacing

    -- Windows navigation
        , ("M-m", windows W.focusMaster)  -- Move focus to the master window
        , ("M-j", windows W.focusDown)    -- Move focus to the next window
        , ("M-k", windows W.focusUp)      -- Move focus to the prev window
        , ("M-S-m", windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
        , ("M-<Backspace>", promote)      -- Moves focused window to master, others maintain order
        , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
        , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack


        --, ("M-C-h", prevWS)   -- Swap focused window with next window
        , ("M-C-<Left>", moveTo Prev NonEmptyWS )   -- Swap focused window with next window
        --, ("M-C-l", nextWS)   -- Swap focused window with next window
        , ("M-C-<Right>", moveTo Next NonEmptyWS)   -- Swap focused window with next window
--        , ((modm,               xK_Down),  nextWS)
--        , ((modm,               xK_Up),    prevWS)
--  	, ((modm .|. shiftMask, xK_Down), shiftToNext >> nextWS)
--  	, ((modm .|. shiftMask, xK_Up),   shiftToPrev >> prevWS)
--        , ((modm .|. shiftMask, xK_Down),  shiftToNext)
--        , ((modm .|. shiftMask, xK_Up),    shiftToPrev)
--        , ((modm,               xK_Right), nextScreen)
--        , ((modm,               xK_Left),  prevScreen)
--        , ((modm .|. shiftMask, xK_Right), shiftNextScreen)
--        , ((modm .|. shiftMask, xK_Left),  shiftPrevScreen)
--        , ((modm,               xK_z),     toggleWS)
        , ("M-z",     toggleWS)


    -- Layouts
        , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout
        , ("M-C-M1-<Up>", sendMessage Arrange)
        , ("M-C-M1-<Down>", sendMessage DeArrange)
        , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
        , ("M-S-<Space>", sendMessage ToggleStruts)     -- Toggles struts
        , ("M-S-n", sendMessage $ MT.Toggle NOBORDERS)  -- Toggles noborder

    -- Increase/decrease windows in the master pane or the stack
        , ("M-S-<Up>", sendMessage (IncMasterN 1))      -- Increase number of clients in master pane
        , ("M-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease number of clients in master pane
        , ("M-C-<Up>", increaseLimit)                   -- Increase number of windows
        , ("M-C-<Down>", decreaseLimit)                 -- Decrease number of windows

    -- Window resizing
        , ("M-h", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M-l", sendMessage Expand)                   -- Expand horiz window width
        , ("M-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
        , ("M-M1-k", sendMessage MirrorExpand)          -- Exoand vert window width

    -- Sublayouts
    -- This is used to push windows to tabbed sublayouts, or pull them out of it.
        , ("M-C-h", sendMessage $ pullGroup L)
        , ("M-C-l", sendMessage $ pullGroup R)
        , ("M-C-k", sendMessage $ pullGroup U)
        , ("M-C-j", sendMessage $ pullGroup D)
        , ("M-C-m", withFocused (sendMessage . MergeAll))
        , ("M-C-u", withFocused (sendMessage . UnMerge))
        , ("M-C-/", withFocused (sendMessage . UnMergeAll))
        , ("M-C-.", onGroup W.focusUp')    -- Switch focus to next tab
        , ("M-C-,", onGroup W.focusDown')  -- Switch focus to prev tab

    -- Scratchpads
        , ("M-C-<Minus>", namedScratchpadAction myScratchPads "terminal")
        , ("M-C-c", namedScratchpadAction myScratchPads "mocp")

        , ("M-<Print>", spawn "sshot -s")

    -- Multimedia Keys
        , ("<XF86AudioPlay>", spawn "current_player play-pause")
        , ("<XF86AudioPause>", spawn "current_player play-pause")
        , ("<XF86AudioStop>", spawn "current_player stop")
        , ("<XF86AudioPrev>", spawn "current_player previous")
        , ("<XF86AudioNext>", spawn "current_player next")
        , ("<XF86AudioMute>", spawn "pamixer -t")
        , ("<XF86AudioLowerVolume>", spawn "pamixer -d 5")
        , ("<XF86AudioRaiseVolume>", spawn "pamixer -i 5")
        , ("<XF86HomePage>", spawn "$BROWSER")
        , ("<XF86Calculator>", runOrRaise "gnome-calculator" (resource =? "gnome-calculator"))
        ]
    -- The following lines are needed for named scratchpads.
          where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))

main :: IO ()
main = do
    -- Launching three instances of xmobar on their monitors.
--    dbus <- mkDbusClient
    _ <- spawnPipe "$XDG_CONFIG_HOME/polybar/launch.sh"
    _ <- spawnPipe "wallpaper restore &"
--    xmproc0 <- spawnPipe "xmobar -x 0 $XMONAD_CONFIG_DIR/xmobar/bar0.hs"
--    xmproc1 <- spawnPipe "xmobar -x 1 $XMONAD_CONFIG_DIR/xmobar/bar2.hs"
--    xmproc2 <- spawnPipe "xmobar -x 2 $XMONAD_CONFIG_DIR/xmobar/bar1.hs"
    -- the xmonad, ya know...what the WM is named after!
    xmonad $ ewmh def
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
        -- Run xmonad commands from command line with "xmonadctl command". Commands include:
        -- shrink, expand, next-layout, default-layout, restart-wm, xterm, kill, refresh, run,
        -- focus-up, focus-down, swap-up, swap-down, swap-master, sink, quit-wm. You can run
        -- "xmonadctl 0" to generate full list of commands written to ~/.xsession-errors.
        -- To compile xmonadctl: ghc -dynamic xmonadctl.hs
        , handleEventHook    = serverModeEventHookCmd
                               <+> serverModeEventHook
                               <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
                               <+> docksEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = workspaceHistoryHook <+> myLogHook <+> updatePointer (0.5, 0.5) (0, 0) -- <+> myPolybarLogHook dbus -- <+> dynamicLogWithPP xmobarPP -- myPolybarLogHook logs into debus ad its handled by xmonad-log
                        {-- ppOutput = \x -> hPutStrLn xmproc0 x  -- >> hPutStrLn xmproc1 x  >> hPutStrLn xmproc2 x
                        , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]"           -- Current workspace in xmobar
                        , ppVisible = xmobarColor "#98be65" "" . clickable              -- Visible but not current workspace
                        , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" "" . clickable -- Hidden workspaces in xmobar
                        , ppHiddenNoWindows = xmobarColor "#c792ea" ""  . clickable     -- Hidden workspaces (no windows)
                        , ppTitle = xmobarColor "#b3afc2" "" . shorten 60               -- Title of active window in xmobar
                        , ppSep =  "<fc=#666666> <fn=1>|</fn> </fc>"                    -- Separators in xmobar
                        , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"            -- Urgent workspace
                        , ppExtras  = [windowCount]                                     -- # of windows current workspace
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        --}
        } `additionalKeysP` myKeys
