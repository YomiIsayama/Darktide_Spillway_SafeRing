local mod = get_mod("SpillwaySafeRing")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enabled",
                type = "checkbox",
                default_value = true,
                title = "enabled",
                tooltip = "enabled_tooltip",
            },
            {
                setting_id = "show_ground_rings",
                type = "checkbox",
                default_value = true,
                title = "show_ground_rings",
                tooltip = "show_ground_rings_tooltip",
            },
            {
                setting_id = "show_world_marker",
                type = "checkbox",
                default_value = true,
                title = "show_world_marker",
                tooltip = "show_world_marker_tooltip",
            },
            {
                setting_id = "pulse",
                type = "checkbox",
                default_value = true,
                title = "pulse",
                tooltip = "pulse_tooltip",
            },
            {
                setting_id = "highlight_color",
                type = "color",
                default_value = { 255, 184, 41, 255 },
                has_alpha = false,
                title = "highlight_color",
                tooltip = "highlight_color_tooltip",
            },
            {
                setting_id = "ground_alpha",
                type = "numeric",
                range = { 20, 100 },
                default_value = 82,
                title = "ground_alpha",
                tooltip = "ground_alpha_tooltip",
            },
            {
                setting_id = "marker_size",
                type = "numeric",
                range = { 40, 120 },
                default_value = 72,
                title = "marker_size",
                tooltip = "marker_size_tooltip",
            },
            {
                setting_id = "marker_max_distance",
                type = "numeric",
                range = { 30, 300 },
                default_value = 200,
                title = "marker_max_distance",
                tooltip = "marker_max_distance_tooltip",
            },
            {
                setting_id = "announce_zone",
                type = "checkbox",
                default_value = false,
                title = "announce_zone",
                tooltip = "announce_zone_tooltip",
            },
        },
    },
}