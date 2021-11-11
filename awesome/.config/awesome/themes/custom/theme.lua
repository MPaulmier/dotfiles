local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme ()

local gfs = require("gears.filesystem")

theme      = {}

-- Theme settings {{{
theme.wallpaper                = wall_dir .. "/wall.jpg"
theme.border_width             = dpi(3)
theme.menu_height              = dpi(16)
theme.menu_width               = dpi(128)

theme.useless_gap              = dpi(5)

theme.tooltip_align            = "top"
theme.tooltip_border_width     = dpi(2)
--}}}

-- Theme fonts {{{
theme.font                     = "Iosevka Bold 11"
theme.mono_font                = "Iosevka 11"
theme.taglist_font             = theme.mono_font
theme.tasklist_font            = theme.font
theme.icon_font                = "FontAwesome 11"
theme.hotkeys_font             = theme.mono_font
theme.hotkeys_description_font = theme.font
--}}}

-- Theme colors {{{
theme.background               = xrdb.background
theme.foreground               = xrdb.foreground
theme.cursor                   = xrdb.cursorColor

theme.black1                   = xrdb.color0
theme.black2                   = xrdb.color8
theme.red1                     = xrdb.color1
theme.red2                     = xrdb.color9
theme.green1                   = xrdb.color2
theme.green2                   = xrdb.color10
theme.yellow1                  = xrdb.color3
theme.yellow2                  = xrdb.color11
theme.blue1                    = xrdb.color4
theme.blue2                    = xrdb.color12
theme.magenta1                 = xrdb.color5
theme.magenta2                 = xrdb.color13
theme.cyan1                    = xrdb.color6
theme.cyan2                    = xrdb.color14
theme.white1                   = xrdb.color7
theme.white2                   = xrdb.color8
theme.grey1                    = "#1d1d29"
theme.grey2                    = "#272b34"

theme.fg_normal                = "#e2ccb0"
theme.fg_focus                 = "#d88166"
theme.fg_urgent                = "#CC9393"
theme.bg_normal                = "#140c0b"
theme.bg_focus                 = "#140c0b"
theme.bg_urgent                = "#2a1f1e"
theme.border_normal            = "#302627"
theme.border_focus             = "#c2745b"
theme.border_marked            = "#CC9393"
theme.taglist_fg_focus         = "#d88166"
theme.tasklist_bg_focus        = "#140c0b"
theme.tasklist_fg_focus        = "#d88166"
theme.gradient_1               = theme.red1
theme.gradient_2               = theme.blue1
theme.gradient_3               = theme.blue2
theme.tooltip_border_color     = theme.grey2
theme.hotkeys_bg               = theme.grey1
theme.hotkeys_modifiers_fg     = theme.blue2
theme.panel_fg                 = theme.grey1

theme                          = theme_assets.recolor_layout(theme, theme.panel_fg)
theme                          = theme_assets.recolor_titlebar_normal(theme, theme.titlebar_fg_normal)
theme                          = theme_assets.recolor_titlebar_focus(theme, theme.titlebar_fg_focus)

--}}}

-- Theme icons {{{
theme.tasklist_disable_icon    = true

theme.awesome_icon             = theme_assets.awesome_icon(theme.menu_height, theme.bg_focus, theme.fg_focus)
theme.menu_submenu_icon        = themedir .. "/submenu.png"

local icons_dir                = themedir .. "/layouts/"
local lain_icons_dir           = userdir .. "/lain/icons/layout/zenburn/"

theme.layout_fairh             = icons_dir .. "fairh.png"
theme.layout_fairv             = icons_dir .. "fairv.png"
theme.layout_floating          = icons_dir .. "floating.png"
theme.layout_magnifier         = icons_dir .. "magnifier.png"
theme.layout_max               = icons_dir .. "max.png"
theme.layout_fullscreen        = icons_dir .. "fullscreen.png"
theme.layout_tilebottom        = icons_dir .. "tilebottom.png"
theme.layout_tileleft          = icons_dir .. "tilelft.png"
theme.layout_tile              = icons_dir .. "tile.png"
theme.layout_tiletop           = icons_dir .. "tiletop.png"
theme.layout_spiral            = icons_dir .. "spiral.png"
theme.layout_dwindle           = icons_dir .. "dwindle.png"
theme.layout_cornernw          = icons_dir .. "cornernw.png"
theme.layout_cornerne          = icons_dir .. "cornerne.png"
theme.layout_cornersw          = icons_dir .. "cornersw.pnf"
theme.layout_cornerse          = icons_dir .. "cornerse.png"
theme.layout_centerfair        = lain_icons_dir .. "centerfair.png"
--}}}

return theme
