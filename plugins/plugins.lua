do

to_id = ""

-- Returns the key (index) in the config.enabled_plugins table
local function plugin_enabled( name )
  for k,v in pairs(_config.enabled_plugins) do
    if name == v then
      return k
    end
  end
  -- If not found
  return false
end

-- Returns true if file exists in plugins folder
local function plugin_exists( name )
  for k,v in pairs(plugins_names()) do
    if name..'.lua' == v then
      return true
    end
  end
  return false
end

local function list_plugins(only_enabled)
  local text = 'پلاگین ها:\n'
  local psum = 0
  for k, v in pairs( plugins_names( )) do    local status = '❌'
    psum = psum+1
    pact = 0
    -- Check if is enabled
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then
        status = '✅️'
      end
      pact = pact+1
    end
    if not only_enabled or status == '✅️' then
      -- get the name
      v = string.match (v, "(.*)%.lua")
      text = text..status..'  '..v..'\n'
    end
  end
  local text = text..'\n'
  return text
end

local function reload_plugins( )
  plugins = {}
  load_plugins()
  return list_plugins(true)
end


local function enable_plugin( plugin_name )
  print('checking if '..plugin_name..' exists')
  -- Check if plugin is enabled
  if plugin_enabled(plugin_name) then
    return 'پلاگین '..plugin_name..' فعال شد.'
  end
  -- Checks if plugin exists
  if plugin_exists(plugin_name) then
    -- Add to the config table
    table.insert(_config.enabled_plugins, plugin_name)
    print(plugin_name..' added to _config table')
    save_config()
    -- Reload the plugins
    return reload_plugins( )
  else
    return 'پلاگین '..plugin_name..' وجود ندارد.'
  end
end

local function disable_plugin( name, chat )
  -- Check if plugins exists
  if not plugin_exists(name) then
    return 'پلاگین '..name..' وجود ندارد.'
  end
  local k = plugin_enabled(name)
  -- Check if plugin is enabled
  if not k then
    return 'پلاگین '..name..' در این گروه غیر فعال شد.'
  end
  -- Disable and reload
  table.remove(_config.enabled_plugins, k)
  save_config( )
  return reload_plugins(true)
end

local function disable_plugin_on_chat(receiver, plugin)
  if not plugin_exists(plugin) then
    return 'پلاگین وجود ندارد.'
  end

  if not _config.disabled_plugin_on_chat then
    _config.disabled_plugin_on_chat = {}
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    _config.disabled_plugin_on_chat[receiver] = {}
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = true

  save_config()
  return 'پلاگین '..plugin..' در این گروه غیر فعال شد.'
end

local function reenable_plugin_on_chat(receiver, plugin)
  if not _config.disabled_plugin_on_chat then
    return 'پلاگین در چت غیر فعال است.'
  end

  if not _config.disabled_plugin_on_chat[receiver] then
  	return 'پلاگین غیر فعال میباشد.'
  end

  if not _config.disabled_plugin_on_chat[receiver][plugin] then
    return 'پلاگین غیر فعال نیست.'
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = false
  save_config()
  return 'پلاگین '..plugin..' در گروه دوباره فعال شد.'
end

local function run(msg, matches)
	to_id = msg.to.id
  -- Show the available plugins
  if permissions(msg.from.id, msg.to.id, "plugins") then
    if matches[1] == 'plugins' or 'پلاگین' then
      return list_plugins()
    end

    -- Re-enable a plugin for this chat
    if matches[1] == 'enable' or 'فعال' and matches[3] == 'gp' or 'گروه' then
      local receiver = get_receiver(msg)
      local plugin = matches[2]
      print("پلاگین "..plugin..' در این گروه فعال شد')
      return reenable_plugin_on_chat(receiver, plugin)
    end

    -- Enable a plugin
    if matches[1] == 'enable' or 'فعال' then
      local plugin_name = matches[2]
      print("فعال: "..matches[2])
      return enable_plugin(plugin_name)
    end

    -- Disable a plugin on a chat
    if matches[1] == 'disable' or 'غیر فعال' and matches[3] == 'gp' or 'گروه' then
      local plugin = matches[2]
      local receiver = get_receiver(msg)
      print("پلاگین "..plugin..' در این گروه غیر فعال شد.')
      return disable_plugin_on_chat(receiver, plugin)
    end

    -- Disable a plugin
    if matches[1] == 'disable' or 'غیر فعال' then
      print("غیر فعال: "..matches[2])
      return disable_plugin(matches[2])
    end

    -- Reload all the plugins!
    if matches[1] == 'reload' or 'ریلود' then
      return reload_plugins(true)
    end
  else
    return
  end
end

return {
  patterns = {
    "^[!/#]plugins$",
    "^(plugins)$",
    "^(پلاگین)$",
    "^[!/#]plugins? (enable) ([%w_%.%-]+)$",
    "^plugins? (enable) ([%w_%.%-]+)$",
    "^پلاگین? (فعال) ([%w_%.%-]+)$",
    "^[!/#]plugins? (disable) ([%w_%.%-]+)$",
    "^plugins? (disable) ([%w_%.%-]+)$",
    "^پلاگین? (غیر فعال) ([%w_%.%-]+)$",
    "^[!/#]plugins? (enable) ([%w_%.%-]+) (gp)",
    "^plugins? (enable) ([%w_%.%-]+) (gp)",
    "^پلاگین? (فعال) ([%w_%.%-]+) (گروه)$",
    "^[!/#]plugins? (disable) ([%w_%.%-]+) (gp)",
    "^plugins? (disable) ([%w_%.%-]+) (gp)",
    "^پلاگین? (غیر فعال) ([%w_%.%-]+) (گروه)$",
    "^plugins? (reload)$",
    "^پلاگین? (ریلود)$",
    "^[!/#]plugins? (reload)$" },
  run = run
}

end
-- Create By Mr.Nitro
