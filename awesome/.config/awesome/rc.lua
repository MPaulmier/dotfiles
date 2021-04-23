-- Possible color palette : #272343 #34a3a3 #bae8e8 #e3f6f5 #fafafa

-- A lot of this config was taken from here :
-- https://github.com/wimstefan/dotfiles/blob/master/config/awesome/rc.lua

-- {{{ Importing modules
local gears = require ("gears")
local awful = require ("awful")
require ("awful.autofocus")
local wibox = require ("wibox")
local lain = require ("lain")
local beautiful = require ("beautiful")
local naughty = require ("naughty")
local menubar = require ("menubar")
local hotkeys_popup = require ("awful.hotkeys_popup").widget
local has_fdo, freedesktop = pcall(require, "freedesktop")
local ruled = require("ruled")
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
            title = "Oops, there were errors during startup!",
            text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
            -- Make sure we don't go into an endless error loop
            if in_error then return end
            in_error = true

            naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, an error happened!",
                    text = tostring(err) })
            in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions

hostname = io.lines("/proc/sys/kernel/hostname")()
TYPE = "laptop"
BAT  = "BAT0"

TEMPFILE = "/sys/devices/platform/coretemp.0/hwmon/hwmon2/temp2_input"

home = os.getenv("HOME")
-- Themes define colours, icons, font and wallpapers.
userdir = home .. "/.config/awesome/"
themedir = userdir .. "/themes/custom/"
wall_dir = home .. "/Images/wallpapers/"

terminal = "urxvt"
editor = "emacsclient -c"

modkey = "Mod4"
altkey = "Mod1"
browser = "firefox"
markup = lain.util.markup
-- }}}

-- {{{ Theme
beautiful.init(themedir .. "theme.lua")
-- }}}

-- {{{Table of layouts
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.fair,
    awful.layout.suit.spiral,
    awful.layout.suit.max,
    lain.layout.termfair.center,
}
-- }}}

-- {{{ Utils
local function pad_to_length(value, ...)
    local max_length = 0
    value = tostring(value)
    for i=1, select('#', ...) do
        local arg = tostring(select(i, ...))
        max_length = math.max(max_length, #arg)
    end
    if max_length > #value then
        value = string.rep(' ', max_length - #value) .. value
    end
    return value
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end},
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end}
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
            before = { menu_awesome },
            after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
            items = {
                menu_awesome,
                menu_terminal,
            }
    })
end


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
        menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

menubar.geometry.x = 200
menubar.geometry.y = 25
menubar.geometry.width = 1400
-- }}}


-- {{{ Wibar

local spr = wibox.widget.textbox('<span color="' .. beautiful.border_focus .. '" weight="bold"> │ </span>')

-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- ALSA volume bar
local icon_alsa = wibox.widget.textbox()
icon_alsa:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.spawn.with_shell(mymixer) end),
        awful.button({ modkey }, 1, function () awful.spawn.with_shell(musicplr1) end),
        awful.button({ altkey }, 1, function () awful.spawn.with_shell(musicplr2) end)))
local volume = lain.widget.alsabar({
        width = 35, ticks = true, ticks_size = 4, step = "2%",
        notification_preset = { font = beautiful.font },
        settings = function()
            if volume_now.status == "off" then
                volume_icon = "&#61478;"
            elseif tonumber(volume_now.level) == 0 then
                volume_icon = "&#61478;"
            elseif tonumber(volume_now.level) <= 50 then
                volume_icon = "&#61479;"
            else
                volume_icon = "&#61480;"
            end
            icon_alsa:set_markup(markup.font(beautiful.icon_font, volume_icon))
        end,
})
volume.bar:buttons(awful.util.table.join(
        awful.button({}, 1, function() -- left click
                awful.spawn.with_shell(mymixer)
        end),
        awful.button({}, 2, function() -- middle click
                awful.spawn(string.format("%s set %s 100%%", volume.cmd, volume.channel))
                volume.update()
        end),
        awful.button({}, 3, function() -- right click
                awful.spawn(string.format("%s set %s toggle", volume.cmd, volume.togglechannel or volume.channel))
                volume.update()
        end),
        awful.button({}, 4, function() -- scroll up
                awful.spawn(string.format("%s set %s 1%%+", volume.cmd, volume.channel))
                volume.update()
        end),
        awful.button({}, 5, function() -- scroll down
                awful.spawn(string.format("%s set %s 1%%-", volume.cmd, volume.channel))
                volume.update()
        end)
))
local volmargin = wibox.container.margin(volume.bar, 8, 0, 5, 5)
local widget_alsa = wibox.container.background(volmargin)

-- Memory widget

local widget_mem = lain.widget.mem({
        settings = function()
            widget:set_markup(markup.font(beautiful.icon_font, "&#61950;") .. markup.font(beautiful.font, "  " .. mem_now.used .. "MB "))
        end
})
local tooltip_mem = awful.tooltip({
        objects = { widget_mem.widget },
        margin_leftright = 20,
        margin_topbottom = 20,
        shape = gears.shape.infobubble,
        timer_function = function()
            local title = "Memory &amp; swap usage"
            local used = pad_to_length(mem_now.used, mem_now.swapused)
            local swapused = pad_to_length(mem_now.swapused, mem_now.used)
            local text
            text = ' <span font="'..beautiful.mono_font..'">'..
                ' <span weight="bold" color="'..beautiful.fg_normal..'">'..title..'</span> \n'..
                ' <span weight="bold">-------------------</span> \n'..
                ' ▪ memory <span color="'..beautiful.fg_normal..'">'..used..'</span> MB \n'..
                ' ▪ swap   <span color="'..beautiful.fg_normal..'">'..swapused..'</span> MB </span>'
            return text
        end
})

-- CPU widget
local widget_cpu = wibox.layout.fixed.horizontal()
local widget_cpu_graph = wibox.widget.graph()
local widget_cpu_text = lain.widget.cpu({
        settings = function()
            widget:set_markup(markup.font(beautiful.icon_font, "&#62171;") .. markup.font(beautiful.font, "  " .. cpu_now.usage .. "% "))
            widget_cpu_graph:add_value(cpu_now.usage/100)
        end
})
widget_cpu_graph:set_width(20)
widget_cpu_graph:set_background_color(beautiful.bg_normal)
widget_cpu_graph:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 18 }, stops = { { 0, beautiful.gradient_1 }, { 0.5, beautiful.gradient_2 }, { 1,beautiful.gradient_3 } } })
widget_cpu:add(widget_cpu_text.widget)
widget_cpu:add(widget_cpu_graph)
widget_cpu:buttons(awful.util.table.join( awful.button({ }, 1, function () awful.spawn.with_shell(mytop) end)))

-- Temp widget
local widget_temp = lain.widget.temp({
        tempfile = TEMPFILE,
        settings = function ()
            widget:set_markup(markup.font(beautiful.icon_font, "&#62152;") .. markup.font(beautiful.font, " " .. coretemp_now .. "° "))
        end
})

-- Power widget
local icon_power = wibox.widget.textbox()
local widget_power = lain.widget.bat({
        battery = BAT,
        notify = "on",
        settings = function()
            if bat_now.status == "N/A" then
                power_icon = markup.font(beautiful.icon_font, "&#xf1e6;") .. markup.font(beautiful.font, "  AC ")
            elseif bat_now.status == "Charging" and tonumber(bat_now.perc) < 100 then
                power_icon = markup.fg.color(beautiful.red1, markup.font(beautiful.icon_font, "&#xf1e6;") .. markup.font(beautiful.font, " " .. bat_now.perc .."%  "))
            elseif bat_now.status == "Charging" then
                power_icon = markup.fg.color(beautiful.green1, markup.font(beautiful.icon_font, "&#xf1e6;") .. markup.font(beautiful.font, " " .. bat_now.perc .."%  "))
            else
                if tonumber(bat_now.perc) <= 10 then
                    power_icon = markup.fg.color(beautiful.red1, markup.font(beautiful.icon_font, "&#xf244;") .. markup.font(beautiful.font, "! " .. bat_now.perc .. "%  "))
                elseif tonumber(bat_now.perc) <= 25 then
                    power_icon = markup.font(beautiful.icon_font, "&#xf243;") .. markup.font(beautiful.font, " " .. bat_now.perc .. "%  ")
                elseif tonumber(bat_now.perc) <= 50 then
                    power_icon = markup.font(beautiful.icon_font, "&#xf242;") .. markup.font(beautiful.font, " " .. bat_now.perc .. "%  ")
                elseif tonumber(bat_now.perc) <= 75 then
                    power_icon = markup.font(beautiful.icon_font, "&#xf241;") .. markup.font(beautiful.font, " " .. bat_now.perc .. "%  ")
                elseif tonumber(bat_now.perc) <= 99 then
                    power_icon = markup.font(beautiful.icon_font, "&#xf240;") .. markup.font(beautiful.font, " " .. bat_now.perc .. "%  ")
                else
                    power_icon = markup.fg.color(beautiful.green1, markup.font(beautiful.icon_font, "&#xf240;") .. markup.font(beautiful.font, " " .. bat_now.perc .. "%  "))
                end
            end
            widget:set_markup(markup.font(beautiful.font, power_icon))

            bat_notification_charged_preset = {
                title   = "Battery full",
                text    = "You can unplug the cable",
                timeout = 15,
                fg      = beautiful.green1,
                bg      = beautiful.black2
            }

            bat_notification_low_preset = {
                title = "Battery low",
                text = "Plug the cable!",
                timeout = nil,
                fg = beautiful.red1,
                bg = beautiful.black2
            }
            bat_notification_critical_preset = {
                title = "Battery exhausted",
                text = "Shutdown imminent",
                timeout = 15,
                fg = beautiful.white1,
                bg = beautiful.black2
            }
        end
})
local tooltip_bat = awful.tooltip({
        objects = { widget_power.widget },
        margin_leftright = 20,
        margin_topbottom = 20,
        shape = gears.shape.infobubble,
        timer_function = function()
            local title = "Power status"
            local tlen = string.len(title)
            local text
            if bat_now.status == 'N/A' then
                text = ' <span font="'..beautiful.mono_font..'">'..
                    ' <span weight="bold" color="'..beautiful.fg_normal..'">'..title..'</span> \n'..
                    ' <span weight="bold">'..string.rep('-', tlen)..'</span> \n'..
                    ' ▪ status    <span color="'..beautiful.fg_normal..'">\n   Desktop </span>'
                text = text..'</span>'
            else
                text = ' <span font="'..beautiful.mono_font..'">'..
                    ' <span weight="bold" color="'..beautiful.fg_normal..'">'..title..'</span> \n'..
                    ' <span weight="bold">'..string.rep('-', tlen)..'</span> \n'
                text = text..' ⚡ level     <span color="'..beautiful.fg_normal..'">'..bat_now.perc..'% </span>\n'
                if bat_now.status == 'Discharging' then
                    text = text..' ▪ status    <span color="'..beautiful.fg_normal..'">discharging </span>\n'
                    text = text..' ◴ time left <span color="'..beautiful.fg_normal..'">'..bat_now.time..' </span>'
                elseif  bat_now.status == 'Charging' then
                    text = text..' ▪ status    <span color="'..beautiful.fg_normal..'">charging </span>\n'
                    text = text..' ◴ time left <span color="'..beautiful.fg_normal..'">'..bat_now.time..' </span>'
                elseif bat_now.status == 'Full' then
                    text = text..' ▪ status    <span color="'..beautiful.fg_normal..'">charged </span>'
                end
                text = text..'</span>'
            end
            return text
        end
})

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
            if c == client.focus then
                c.minimized = true
            else
                -- Without this, the following
                -- :isvisible() makes no sense
                c.minimized = false
                if not c:isvisible() and c.first_tag then
                    c.first_tag:view_only()
                end
                -- This will also un-minimize
                -- the client, if needed
                client.focus = c
                c:raise()
            end
    end),
    awful.button({ }, 4, function ()
            awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
            awful.client.focus.byidx(-1)
end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper1 and s.index == 1 then
        local wallpaper = beautiful.wallpaper1
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    elseif beautiful.wallpaper2 and s.index == 2 then
        -- I use two monitors on my desktop and don't have the same
        -- wallpaper on each one (mainly because one is vertically
        -- oriented)
        local wallpaper = beautiful.wallpaper2
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
        -- Wallpaper
        set_wallpaper(s)

        -- Each screen has its own tag table.
        awful.tag({ "home", "work", "web", "emacs" }, s,
            {awful.layout.layouts[2], awful.layout.layouts[2], awful.layout.layouts[4], awful.layout.layouts[4]})

        -- Create a promptbox for each screen
        s.mypromptbox = awful.widget.prompt()
        -- Create an imagebox widget which will contain an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        s.mylayoutbox = awful.widget.layoutbox {
            screen  = s,
            buttons = {
                awful.button({ }, 1, function () awful.layout.inc( 1) end),
                awful.button({ }, 3, function () awful.layout.inc(-1) end),
                awful.button({ }, 4, function () awful.layout.inc(-1) end),
                awful.button({ }, 5, function () awful.layout.inc( 1) end),
            }
        }
        -- Create a taglist widget
        s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

        -- Create a tasklist widget
        s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

        -- Create the wibox
        s.mywibox = awful.wibar({ y = "10", height = "20", width = "1800", shape = gears.shape.rounded_rect, border_width = "5", border_color = "#000000", screen = s })

        -- Add widgets to the wibox
        s.mywibox:setup {
            widget = wibox.container.margin,
            margins = 10,
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                s.mylayoutbox,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist,
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.systray(),
                icon_alsa,
                widget_alsa,
                spr,
                widget_mem,
                spr,
                widget_cpu,
                spr,
                widget_temp,
                spr,
                widget_power,
                spr,
                mytextclock,
            },
        }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
        awful.button({ }, 3, function () mymainmenu:toggle() end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
        {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
        {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
        {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
        {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j", function () awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}),
    awful.key({ modkey,           }, "k", function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}),
    awful.key({ modkey,           }, "w", function () mymainmenu:show()            end,
        {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
        {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
        {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
        {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
        {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal)       end,
        {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "s", function () awful.spawn("systemctl suspend") end,
        {description = "suspend system", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
        {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
        {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
        {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
        {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
        {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
        {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
        {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
        {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
        function ()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        {description = "lua execute prompt", group = "awesome"}),

    awful.key({ modkey }, "i",
        function ()
            awful.prompt.run {
                prompt = "Go to issue: ",
                textbox = awful.screen.focused().mypromptbox.widget,
                exe_callback = function (s)
                    os.execute("firefox --new-tab https://support.coopengo.com/issues/" .. s)
                end,
                history_patch = awful.util.get_cache_dir() .. "/history_issues"
            }
        end,
        {desciption = "search for issue in coog's redmine", group = "awersome"}),

    -- Screen brightness control
    awful.key({}, "XF86MonBrightnessUp",
        function ()
            os.execute("brightnessctl s +10% intel_backlight")
        end,
        {description = "Raise brightness", group = "controls"}),
    awful.key({}, "XF86MonBrightnessDown",
        function ()
            os.execute("brightnessctl s 10%- intel_backlight")
        end,
        {description = "Lower brightness", group = "controls"}),

    -- Alsa volume control
    awful.key({}, "XF86AudioRaiseVolume",
        function ()
            os.execute(string.format("amixer set %s 1%%+", volume.channel))
            volume.notify()
        end,
        {description = "Raise volume", group = "controls"}),
    awful.key({}, "XF86AudioLowerVolume",
        function ()
            os.execute(string.format("amixer set %s 1%%-", volume.channel))
            volume.notify()
        end,
        {description = "Lower volume", group = "controls"}),
    awful.key({}, "XF86AudioMute",
        function ()
            os.execute(string.format("amixer set %s toggle", volume.togglechannel or volume.channel))
            volume.notify()
        end,
        {description = "Mute volume", group = "controls"}),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
        {description = "show the menubar", group = "launcher"}),

    -- Applications
    awful.key({ modkey,           }, "e",
        function () awful.spawn(editor) end,
        {description = "Emacs", group = "applications"}),
    awful.key({ modkey,           }, "b",
        function () awful.spawn(browser) end,
        {description = "Firefox", group = "applications"}),
    awful.key({ modkey,           }, "l",
        function () awful.spawn("libreoffice") end,
        {description = "LibreOffice", group = "applications"}),
    awful.key({ modkey, "Shift"   }, "t",
        function () awful.spawn("thunar") end,
        {description = "Thunar", group = "applications"}),
    awful.key({                   }, "Print",
        function() awful.util.spawn("screengrab") end,
        {description = "Print screen", group = "controls"}),
    awful.key({ modkey, "Shift"   }, "x",
        function () awful.spawn("lxappearance") end,
        {description = "Lxappearance", group = "applications"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
        {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
        {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
        {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
        {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 4 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))
-- }}}

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
ruled.client.append_rules {
    -- All clients will match this rule.
    {
        rule = { },
        properties = { border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            size_hints_honor = false,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            type = { "dialog" },
            class = {
                "Arandr",
                "Nm-connection-editor",
            },
            name = {
                "Event Tester",
            }
        },
        properties = {
            floating = true,
            placement = awful.placement.centered
        }
    },

    -- Emacs
    {
        rule = { class = "Emacs" },
        properties = {
            tag = "emacs",
            switchtotag = true,
        }
    },

    -- Web
    {
        rule_any = {
            instance = {
                "Navigator",
                "google-chrome",
            }
        },
        properties = {
            tag = "web"
        }
    },

    -- Tryton
    {
        rule = { class = "Tryton" },
        properties = {
            size_hints_honor = true
        }
    }
}

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- if not awesome.startup then awful.client.setslave(c) end

        if awesome.startup and
            not c.size_hints.user_position
            and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(c)
        end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autostart
awful.spawn.with_shell("killall compton")
awful.spawn.with_shell("compton &")
-- }}}
