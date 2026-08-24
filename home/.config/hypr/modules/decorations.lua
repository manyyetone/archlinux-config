-- ---- LOOK AND FEEL (DECORATIONS) ----

-- Refer to https://wiki.hypr.land/Configuring/Variables/

-- Import the colors table (Ensure this path matches where you save colors.lua)
local colors = require("modules/colors") 

hl.config({
    general = {
        gaps_in = 7,
        gaps_out = 15,

        border_size = 1,

        col = {
        active_border = "rgba(55555599)",
        inactive_border = "rgba(2a2a2a55)",
    },

        resize_on_border = true,
        allow_tearing = true,

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 10,

        active_opacity = 0.85,
        inactive_opacity = 0.80,

        shadow = {
            enabled = true,
            range = 18,
            render_power = 5,
            color = "rgba(000000aa)",
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            ignore_opacity = true,

            noise = 0.07,
            contrast = 1.5,
            vibrancy = 0.2,

            xray = false,
            new_optimizations = true,
        },
    },
})