local json = require('lunajson')

CONFIG_PATH = "Config\\Config.json"
Config = json.parse_file(CONFIG_PATH)
-- Allow the modest menu user to change the config
for k, v in pairs(Config) do
	-- for booleans add a toggle
	if type(v) == "boolean" then
		menu.add_toggle(k,
			function()
				return v
			end,
			function(value)
				Config[k] = value
			end)
	else
		-- display the value
		menu.add_action(k .. ": " .. tostring(v), function()
			-- open the json file
			os.execute("start " .. CONFIG_PATH)
		end)
	end
end
