return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`SpillwaySafeRing` encountered an error loading the Darktide Mod Framework.")

		new_mod("SpillwaySafeRing", {
			mod_script       = "SpillwaySafeRing/scripts/mods/SpillwaySafeRing/SpillwaySafeRing",
			mod_data         = "SpillwaySafeRing/scripts/mods/SpillwaySafeRing/SpillwaySafeRing_data",
			mod_localization = "SpillwaySafeRing/scripts/mods/SpillwaySafeRing/SpillwaySafeRing_localization",
		})
	end,
	packages = {},
}
