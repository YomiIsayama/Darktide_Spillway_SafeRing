local mod = get_mod("SpillwaySafeRing")
local MarkerTemplate = mod:io_dofile("SpillwaySafeRing/scripts/mods/SpillwaySafeRing/SpillwaySafeRing_marker")

local EffectTemplates = require("scripts/settings/fx/effect_templates")
local RenegadeWizardActions = require("scripts/settings/breed/breed_actions/renegade/renegade_wizard_actions")

local EFFECT_TEMPLATE = EffectTemplates.renegade_psyker_boss_circle_dance
local CIRCLE_SETTINGS = RenegadeWizardActions.dance.circle_settings
local DECAL_UNIT = "content/levels/training_grounds/fx/decal_aoe_indicator"
local DECAL_PACKAGE = "content/levels/training_grounds/missions/mission_tg_basic_combat_01"
local DECAL_MATERIAL_SLOT = "projector"
local RING_COLOR = { 0.72, 0.16, 1 }
local RING_Z_OFFSET = 0.18
local FILL_RING_SPACING = 0.10
local MARKER_Z_OFFSET = 2.1
local WORLD_MARKER_ELEMENT = "HudElementWorldMarkers"

local instances_by_template = {}
local instances = {}

local function refresh_settings()
    mod._spillway_settings = {
        enabled = mod:get("enabled"),
        show_ground_rings = mod:get("show_ground_rings"),
        show_world_marker = mod:get("show_world_marker"),
        pulse = mod:get("pulse"),
        ground_alpha = mod:get("ground_alpha") / 100,
        marker_size = mod:get("marker_size"),
        marker_max_distance = mod:get("marker_max_distance"),
        announce_zone = mod:get("announce_zone"),
    }
end

local function settings()
    if not mod._spillway_settings then
        refresh_settings()
    end

    return mod._spillway_settings
end

local function world_markers_element()
    local ui_manager = Managers.ui
    local hud = ui_manager and ui_manager:get_hud()
    local element = hud and hud:element(WORLD_MARKER_ELEMENT)

    return element
end

local function destroy_ground_unit(instance, unit)
    if not unit then
        return
    end

    if Unit.alive(unit) then
        World.destroy_unit(instance.world, unit)
    end
end

local function destroy_ground_rings(instance)
    local fill_rings = instance.fill_rings

    if fill_rings then
        for i = 1, #fill_rings do
            destroy_ground_unit(instance, fill_rings[i].unit)
        end
    end

    instance.fill_rings = nil
    instance.fill_zone = nil
end

local function remove_marker(instance)
    local marker_id = instance.marker_id

    if marker_id and instance.marker_element and instance.marker_element == world_markers_element() then
        Managers.event:trigger("remove_world_marker", marker_id)
    end

    instance.marker_id = nil
    instance.marker_element = nil
    instance.marker_zone = nil
end

local function cleanup_instance(instance)
    if not instance then
        return
    end

    remove_marker(instance)
    destroy_ground_rings(instance)

    instances_by_template[instance.template_data] = nil

    local index = table.find(instances, instance)

    if index then
        table.remove(instances, index)
    end
end

local function cleanup_all()
    for i = #instances, 1, -1 do
        cleanup_instance(instances[i])
    end

    table.clear(instances_by_template)
    table.clear(instances)
end

local function get_instance(template_data)
    local instance = instances_by_template[template_data]

    if not instance then
        instance = {
            template_data = template_data,
        }

        instances_by_template[template_data] = instance
        instances[#instances + 1] = instance
    end

    return instance
end

local function set_decal_color_and_scale(instance, unit, radius, alpha)
    if not Unit.alive(unit) then
        return
    end

    local diameter = radius * 2
    local colour = Quaternion.identity()

    Quaternion.set_xyzw(colour, RING_COLOR[1], RING_COLOR[2], RING_COLOR[3], 0)
    Unit.set_local_scale(unit, 1, Vector3(diameter, diameter, 1))
    Unit.set_vector4_for_material(unit, DECAL_MATERIAL_SLOT, "particle_color", colour, true)
    Unit.set_scalar_for_material(unit, DECAL_MATERIAL_SLOT, "color_multiplier", alpha)
end

local function create_ground_ring(instance, radius, alpha)
    local position = instance.center + Vector3(0, 0, RING_Z_OFFSET)
    local unit = World.spawn_unit_ex(instance.world, DECAL_UNIT, nil, position)

    if not Unit.alive(unit) then
        return nil
    end

    set_decal_color_and_scale(instance, unit, radius, alpha)

    return unit
end

local function ensure_decal_package(instance)
    local package_manager = Managers.package

    if not package_manager or package_manager:has_loaded(DECAL_PACKAGE) then
        return true
    end

    if not instance.package_loading then
        instance.package_loading = true

        package_manager:load(DECAL_PACKAGE, "SpillwaySafeRing", function()
            instance.package_loading = false

        end)
    end

    return false
end

local function update_ground_rings(instance, t)
    local current_settings = settings()

    if not current_settings.show_ground_rings then
        destroy_ground_rings(instance)
        return
    end

    if not ensure_decal_package(instance) then
        return
    end

    local safe_zone = instance.safe_zone
    local circle = CIRCLE_SETTINGS[safe_zone]

    if not circle then
        destroy_ground_rings(instance)
        return
    end

    local fill_rings = instance.fill_rings
    local should_rebuild = instance.fill_zone ~= safe_zone or not fill_rings

    if not should_rebuild then
        for i = 1, #fill_rings do
            if not Unit.alive(fill_rings[i].unit) then
                should_rebuild = true

                break
            end
        end
    end

    if should_rebuild then
        destroy_ground_rings(instance)

        fill_rings = {}
        instance.fill_rings = fill_rings
        instance.fill_zone = safe_zone

        local inner_radius = circle.inner_radius
        local outer_radius = circle.outer_radius
        local width = outer_radius - inner_radius
        local num_rings = math.max(2, math.ceil(width / FILL_RING_SPACING))
        local step = width / num_rings

        for i = 1, num_rings do
            local radius = inner_radius + (i - 0.5) * step
            local unit = create_ground_ring(instance, radius, current_settings.ground_alpha * 0.32)

            if unit then
                fill_rings[#fill_rings + 1] = {
                    unit = unit,
                    radius = radius,
                }
            end
        end
    end

    local fill_alpha = current_settings.ground_alpha * 0.32

    if current_settings.pulse then
        fill_alpha = fill_alpha * (0.62 + 0.38 * math.abs(math.sin(t * 4.5)))
    end

    for i = 1, #fill_rings do
        local fill_ring = fill_rings[i]

        set_decal_color_and_scale(instance, fill_ring.unit, fill_ring.radius, fill_alpha)
    end
end

local function add_marker(instance)
    local element = world_markers_element()

    if not element then
        return false
    end

    local safe_zone = instance.safe_zone
    local label = string.format("%s  %d/%d", mod:localize("safe_marker"), safe_zone, #CIRCLE_SETTINGS)
    local position = instance.center + Vector3(0, 0, MARKER_Z_OFFSET)
    local data = {
        color = { 190, 70, 255 },
        size = settings().marker_size,
        icon = "content/ui/materials/hud/interactions/icons/location",
        label = label,
        max_distance = settings().marker_max_distance,
    }

    instance.marker_zone = safe_zone
    instance.marker_element = element

    Managers.event:trigger("add_world_marker_position", MarkerTemplate.name, position, function(id)
        if instances_by_template[instance.template_data] then
            instance.marker_id = id
        end
    end, data)

    return instance.marker_id ~= nil
end

local function update_marker(instance)
    local current_settings = settings()

    if not current_settings.show_world_marker then
        remove_marker(instance)
        return
    end

    if instance.marker_id and instance.marker_zone == instance.safe_zone then
        return
    end

    remove_marker(instance)
    add_marker(instance)
end

local function notify_zone_change(instance, safe_zone, t)
    if instance.announced_zone == safe_zone then
        return
    end

    instance.announced_zone = safe_zone
    instance.zone_change_t = t

    if settings().announce_zone then
        mod:notify(mod:localize("zone_changed", safe_zone, #CIRCLE_SETTINGS))
    end
end

local function update_instance(template_data, template_context, dt, t)
    local game_session = template_context and template_context.game_session
    local game_object_id = template_data and template_data.game_object_id
    local unit = template_data and template_data.unit

    if not game_session or not game_object_id or not unit or not Unit.alive(unit) then
        return
    end

    local safe_zone = GameSession.game_object_field(game_session, game_object_id, "safe_zone")

    if not safe_zone or safe_zone <= 0 or safe_zone > #CIRCLE_SETTINGS then
        return
    end

    local center = GameSession.game_object_field(game_session, game_object_id, "center_position")

    if not center then
        center = POSITION_LOOKUP[unit]
    end

    if not center then
        return
    end

    local instance = get_instance(template_data)

    instance.world = Unit.world(unit)
    instance.center = center
    instance.safe_zone = safe_zone

    if instance.zone ~= safe_zone then
        instance.zone = safe_zone
        notify_zone_change(instance, safe_zone, t)
    end

    update_ground_rings(instance, t)
    update_marker(instance)
end

refresh_settings()

if DEDICATED_SERVER then
    return
end

if EFFECT_TEMPLATE then
    mod:hook_safe(EFFECT_TEMPLATE, "update", function(template_data, template_context, dt, t)
        if not settings().enabled then
            cleanup_instance(instances_by_template[template_data])

            return
        end

        update_instance(template_data, template_context, dt, t)
    end)

    mod:hook_safe(EFFECT_TEMPLATE, "stop", function(template_data)
        cleanup_instance(instances_by_template[template_data])
    end)
end

mod:hook("HudElementWorldMarkers", "_template_by_type", function(func, self, marker_type, clone)
    if marker_type == MarkerTemplate.name then
        return clone and table.clone(MarkerTemplate) or MarkerTemplate
    end

    return func(self, marker_type, clone)
end)

mod.on_setting_changed = function()
    refresh_settings()
    cleanup_all()
end

mod.on_disabled = function()
    cleanup_all()
end

mod.on_unload = function()
    cleanup_all()
end
mod.on_game_state_changed = function(status)
    if status == "exit" then
        cleanup_all()
    end
end