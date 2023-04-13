local lfs = require('lfs')

--- Gets the type of file from the prefixed extension
--- @param filename string
--- @return string type
local function get_type(filename)
	return string.match(filename, "%.(%w+)$")
end

--- Adds a title to the menu
--- @param title string to add
local function add_title(title)
	menu.add_action('== ' .. title .. ' ==', function()
	end)
end

--- Sorts a directory by number prefix
--- @param dir string[]
local function sort(dir)
	local function sort_func(a, b)
		local a_num = tonumber(string.match(a, "^(%d+) "))
		local b_num = tonumber(string.match(b, "^(%d+) "))
		if a_num ~= nil and b_num ~= nil then
			return a_num < b_num
		end
		return a < b
	end
	table.sort(dir, sort_func)
end

--- Removes the number prefix used for sorting from a basename
--- @param file_name string
--- @return string
local function denum(file_name)
	-- gsub returns 2 values, the first is what we want
	return string.gsub(file_name, "^(%d+) ", "")[1]
end

--- Recursively builds the menu from the scripts directory
--- @param path string
local function build_menu(path, menu_ref)
	local dir = sort(lfs.dir(path))
	for entry in dir do
		-- Ignore current and parent dir and prefixed files
		if entry ~= "." and entry ~= ".." and not string.match(entry, "^(" .. table.concat(Config.IgnorePrefixes, "|") .. ")") then
			local entry_path = path .. "/" .. entry
			local entry_name = denum(entry)
			local attr = lfs.attributes(entry_path)
			local type = get_type(entry)

			if attr.mode == "directory" then
				local submenu = menu_ref:add_submenu(entry_name)
				build_menu(entry_path, submenu)
			elseif attr.mode == "file" then
				ScriptConfig = Config["Scripts"][denum(string.gsub(path, "/", "."))][string.gsub(entry_name, "%..+$", "")]

				local _menu = menu
				menu = menu_ref

				if type == "group" then
					add_title(entry_name)
					require(entry_path)
				elseif type == "action" then
					local action_callback = require(entry_path)
					menu_ref:add_action(entry_name, action_callback)
				elseif type == "playerConfig" then
					menu.add_toggle(entry_name,
						function()
							if localplayer == nil then
								return nil
							end
							return localplayer:get_config_flag(FLAG)
						end,
						function(value)
							localplayer:set_config_flag(FLAG, value)
						end)
					--End
				else
					require(entry_path)
				end
				menu = _menu
			end
		end
	end
end

build_menu(".", menu)
