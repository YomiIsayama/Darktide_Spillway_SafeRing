local UIWidget = require("scripts/managers/ui/ui_widget")

local template = {}
local DEFAULT_SIZE = 72
local DEFAULT_COLOR = { 190, 70, 255 }

template.name = "spillway_safe_ring"
template.size = { DEFAULT_SIZE, DEFAULT_SIZE }
template.min_distance = 0
template.max_distance = 200
template.position_offset = { 0, 0, 0 }
template.check_line_of_sight = false
template.screen_clamp = false
template.using_smart_tag_system = false

template.create_widget_defintion = function(_, scenegraph_id)
    return UIWidget.create_definition({
        {
            pass_type = "texture",
            style_id = "background",
            value = "content/ui/materials/hud/interactions/frames/point_of_interest_back",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                size = { DEFAULT_SIZE, DEFAULT_SIZE },
                offset = { 0, 0, 1 },
                color = { 215, 28, 0, 55 },
            },
        },
        {
            pass_type = "texture",
            style_id = "pulse",
            value = "content/ui/materials/hud/interactions/frames/pulse_effect",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                size = { DEFAULT_SIZE, DEFAULT_SIZE },
                offset = { 0, 0, 2 },
                color = { 210, DEFAULT_COLOR[1], DEFAULT_COLOR[2], DEFAULT_COLOR[3] },
            },
        },
        {
            pass_type = "texture",
            style_id = "ring",
            value = "content/ui/materials/hud/interactions/frames/point_of_interest_top",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                size = { DEFAULT_SIZE, DEFAULT_SIZE },
                offset = { 0, 0, 3 },
                color = { 255, DEFAULT_COLOR[1], DEFAULT_COLOR[2], DEFAULT_COLOR[3] },
            },
        },
        {
            pass_type = "texture",
            style_id = "icon",
            value_id = "icon",
            value = "content/ui/materials/hud/interactions/icons/location",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                size = { 38, 38 },
                offset = { 0, 0, 4 },
                color = { 255, DEFAULT_COLOR[1], DEFAULT_COLOR[2], DEFAULT_COLOR[3] },
            },
        },
        {
            pass_type = "text",
            style_id = "label_shadow",
            value_id = "label",
            value = "",
            style = {
                font_type = "proxima_nova_bold",
                font_size = 20,
                horizontal_alignment = "center",
                vertical_alignment = "center",
                text_horizontal_alignment = "center",
                text_vertical_alignment = "top",
                size = { 300, 42 },
                offset = { 1, DEFAULT_SIZE * 0.5 + 6, 4 },
                text_color = { 245, 0, 0, 0 },
            },
        },
        {
            pass_type = "text",
            style_id = "label",
            value_id = "label",
            value = "",
            style = {
                font_type = "proxima_nova_bold",
                font_size = 20,
                horizontal_alignment = "center",
                vertical_alignment = "center",
                text_horizontal_alignment = "center",
                text_vertical_alignment = "top",
                size = { 300, 42 },
                offset = { 0, DEFAULT_SIZE * 0.5 + 5, 5 },
                text_color = { 255, DEFAULT_COLOR[1], DEFAULT_COLOR[2], DEFAULT_COLOR[3] },
            },
        },
    }, scenegraph_id)
end

local function set_rgb(color, rgb)
    color[2], color[3], color[4] = rgb[1], rgb[2], rgb[3]
end

template.on_enter = function(widget, marker)
    local data = marker.data
    local rgb = data.color or DEFAULT_COLOR
    local size = data.size or DEFAULT_SIZE
    local style = widget.style

    style.background.size[1], style.background.size[2] = size, size
    style.ring.size[1], style.ring.size[2] = size, size
    style.pulse.size[1], style.pulse.size[2] = size, size

    set_rgb(style.ring.color, rgb)
    set_rgb(style.pulse.color, rgb)
    set_rgb(style.icon.color, rgb)
    set_rgb(style.label.text_color, rgb)

    style.background.color[2] = math.floor(rgb[1] * 0.15)
    style.background.color[3] = math.floor(rgb[2] * 0.12)
    style.background.color[4] = math.floor(rgb[3] * 0.22)

    local icon_size = math.floor(size * 0.52)

    style.icon.size[1], style.icon.size[2] = icon_size, icon_size
    style.label.offset[2] = size * 0.5 + 5
    style.label_shadow.offset[2] = size * 0.5 + 6

    widget.content.icon = data.icon or widget.content.icon
    widget.content.label = data.label or ""
    marker.template.max_distance = data.max_distance or template.max_distance
end

template.update_function = function(_, _, widget, marker, template, dt, t)
    local progress = (math.sin(t * 5.5) + 1) * 0.5
    local size = marker.data.size or DEFAULT_SIZE
    local pulse_size = size * (1 + progress * 0.22)
    local style = widget.style

    style.pulse.size[1], style.pulse.size[2] = pulse_size, pulse_size
    style.pulse.color[1] = 105 + math.floor(progress * 120)

    return true
end

return template