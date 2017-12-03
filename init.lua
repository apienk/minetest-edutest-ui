if not minetest.global_exists("sfinv") then
	minetest.log("warning", "edutest_ui: Failed to detect sfinv. Mod loaded but unused.")
	return
end

local edufilter = ""

-- Set default itempacks and load user's itempacks from file
local itempacks = {
	{name = "Survival Kit", pack = {"default:pick_wood 1", "default:axe_wood 1", "default:apple 10"}},
	}
local load_itempacks = function(player)
	local target = player:get_player_name()
	local itempackfile = io.open(minetest.get_worldpath() .. "/" .. target .. ".itempacks", "r")
	if itempackfile then
		itempackfile:close()
		print("[edutest-ui] Loading itempacks for " .. target)
		for line in io.lines(minetest.get_worldpath() .. "/" .. target .. ".itempacks") do
			local v = loadstring("return "..line)()
			local d = false
			for _,c in pairs(itempacks) do
				if v.name == c.name then d = true end
			end
			if not d then table.insert(itempacks, v) end
		end
	end
end

local form1_update = function(player, fields)
	local cmddef = minetest.chatcommands
	local target = player:get_player_name()
	if not minetest.check_player_privs(player, { instructor = true}) then
		minetest.chat_send_player(target, "---Forbidden. No instructor privileges.")
		return
	end
	-- Give me
	if fields.gvme then
		if fields.items and fields.items ~= "Choose item" then
			cmddef["giveme"].func(target, fields.items .. " " .. fields.numb)
			minetest.chat_send_player(target, "---You gave " .. fields.items .. " to yourself")
		else
			minetest.chat_send_player(target, "---Please specify an item")
		end
		return
	end
	-- Give students
	if fields.gvst then
		if fields.items and fields.items ~= "Choose item" and fields.students ~= "Choose students" then
			if fields.students == "All students" then
				cmddef["every_student"].func(target, "give subject " .. fields.items .. " " .. fields.numb)
			else
				if minetest.get_player_by_name(fields.students):is_player_connected() then
					cmddef["give"].func(target, fields.students .. " " .. fields.items .. " " .. fields.numb)
				end
			end
			minetest.chat_send_player(target, "---You gave " .. fields.items .. " to " .. fields.students)
		else
			minetest.chat_send_player(target, "---Please specify student(s) and an item")
		end
		return
	end
	-- Check student's inventory
	if fields.chki then
		if fields.students ~= "All students" and fields.students ~= "Choose students" then
			local invgui = "size[8,4]"
			local invpl = minetest.get_inventory({type="player", name=fields.students})
			for i = 0,3 do
				for j = 0,7 do
					local k = i*8+j+1
					invgui = invgui .. "item_image_button[" .. j .. "," .. i .. ";1,1;" .. invpl:get_stack("main",k):get_name() .. ";inv" .. k ..";\n\n\b\b\b" .. invpl:get_stack("main",k):get_count() .."]"
				end
			end
			minetest.show_formspec(target, "invform", invgui)
		else
			minetest.chat_send_player(target, "---Please specify a student")
		end
	end
	-- Clear students inventory
	if fields.clri then
		if fields.students ~= "Choose students" then
			if fields.students == "All students" then
				cmddef["every_student"].func(target, "clearinv subject")
			else
				cmddef["clearinv"].func(target, fields.students)
			end
			minetest.chat_send_player(target, "---You cleared inventory of " .. fields.students)
		else
			minetest.chat_send_player(target, "---Please specify student(s)")
		end
		return
	end
	-- Clear my inventory
	if fields.clrm then
		cmddef["clearinv"].func(target, target)
		minetest.chat_send_player(target, "---You cleared your inventory")
		return
	end
	-- Copy students inventory
	if fields.cpyi then
		if fields.students ~= "All students" and fields.students ~= "Choose students" then
			cmddef["clearinv"].func(target, target)
			cmddef["copyinv"].func(target, fields.students)
			minetest.chat_send_player(target, "---You cloned " .. fields.students .. "\'s inventory to your inventory (your inventory was deleted)")
		else
			minetest.chat_send_player(target, "---Please specify a student")
		end
		return
	end
	-- Heal
	if fields.hlst then
		if fields.students ~= "Choose students" then
			if fields.students == "All students" then
				minetest.chat_send_player(target, "Trying: /every_student heal All students")
				cmddef["every_student"].func(target, "heal subject")
			else
				minetest.chat_send_player(target, "Trying: /heal " .. fields.students)
				cmddef["heal"].func(target, fields.students)
			end
			minetest.chat_send_player(target, "---You healed " .. fields.students)
		else
			minetest.chat_send_player(target, "---Please specify student(s)")
		end
		return
	end
	-- Heal me
	if fields.hlme then
		cmddef["heal"].func(target, target)
		minetest.chat_send_player(target, "---You healed yourself")
		return
	end
	-- Freeze
	if fields.frze then
		if fields.students ~= "Choose students" then
			if fields.students == "All students" then
				cmddef["every_student"].func(target, "freeze subject")
			else
				cmddef["freeze"].func(target, fields.students)
			end
			minetest.chat_send_player(target, "---You froze " .. fields.students)
		else
			minetest.chat_send_player(target, "---Please specify student(s)")
		end
		return
	end
	-- Unfreeze
	if fields.unfr then
		if fields.students ~= "Choose students" then
			if fields.students == "All students" then
				cmddef["every_student"].func(target, "unfreeze subject")
			else
				cmddef["unfreeze"].func(target, fields.students)
			end
			minetest.chat_send_player(target, "---You unfroze " .. fields.students)
		else
			minetest.chat_send_player(target, "---Please specify student(s)")
		end
		return
	end
	-- Pulverize
	if fields.empt then
		cmddef["pulverize"].func(target, "")
		minetest.chat_send_player(target, "---You destroyed the item you wielded")
		return
	end
	-- Filter items
	if fields.filtr and fields.fltr then
		edufilter = fields.filtr
		return
	end
	-- Clear filter
	if fields.filtr and fields.fltc then
		edufilter = ""
		return
	end
	-- Message
	if fields.mesg then
		if fields.students ~= "Choose students" and fields.msgtxt then
			if fields.students == "All students" then
				cmddef["every_student"].func(target, "msg subject " .. fields.msgtxt)
			else
				cmddef["msg"].func(target, fields.students .. " " .. fields.msgtxt)
			end
			minetest.chat_send_player(target, "---You sent a private message (" .. fields.msgtxt .. ") to " .. fields.students)
		else
			minetest.chat_send_player(target, "---Please specify student(s) and a message")
		end
		return
	end
	-- Give itempack
	if fields.ipgv then
		if fields.itemp ~= "Choose itempack" and fields.students ~= "Choose students" then
			for _,p in pairs(itempacks) do
				if p.name == fields.itemp then
					for i,a in pairs(p.pack) do
						if fields.students == "All students" then
							cmddef["every_student"].func(target, "give subject " .. a)
						elseif minetest.get_player_by_name(fields.students):is_player_connected() then
							cmddef["give"].func(target, fields.students .. " " .. a)
						end
					end
				minetest.chat_send_player(target, "---You gave itempack " .. fields.itemp .. " to " .. fields.students)
				end
			end
		else
			minetest.chat_send_player(target, "---Please specify student(s) and an itempack")
		end
		return
	end
	-- Give me itempack
	if fields.ipgm then
		if fields.itemp ~= "Choose itempack" then
			for _,p in pairs(itempacks) do
				if p.name == fields.itemp then
					for i,a in pairs(p.pack) do
						cmddef["giveme"].func(target, a)
					end
				minetest.chat_send_player(target, "---You gave itempack " .. fields.itemp .. " to yourself")
				end
			end
		else
			minetest.chat_send_player(target, "---Please specify an itempack")
		end
		return
	end
	-- Set itempack from inventory
	if fields.ipst then
		if fields.ipname ~= "" then
			-- Check if proper name
			if string.find(fields.ipname, "[^\1-\127]") then
				minetest.chat_send_player(target, "---itempack name must contain ASCII characters only")
				return
			end
			-- Get user's inventory
			local stacks, i, a = {}, "", ""
			local pinv = minetest.get_inventory({type="player", name=target})
			for _,s in pairs(pinv:get_list("main")) do
				i = s:get_definition().name
				a = s:get_count()
				if a > 0 then
					table.insert(stacks, i .. " " .. a)
				end
			end
			-- If name exists delete
			for x,p in pairs(itempacks) do
				if p.name == fields.ipname then
					table.remove(itempacks, x)
				end
			end
			-- Store
			table.insert(itempacks, {name=fields.ipname, pack=stacks})
			minetest.chat_send_player(target, "---You have stored your current inventory as itempack " .. fields.ipname)
			-- Save to file
			local itempackfile = io.open(minetest.get_worldpath() .. "/" .. target .. ".itempacks", "w")
			local ipickle
			for _,p in pairs(itempacks) do
				ipickle = '{ name=\"'..p.name..'\", pack={ '
				local frst = true
				for x,s in pairs(p.pack) do
					if frst then
						ipickle = ipickle .. '\"' .. s .. '\"'
						frst = false
					else
						ipickle = ipickle .. ', \"' .. s .. '\"'
					end
				end
				itempackfile:write(ipickle..' }}\n')
			end
			io.close(itempackfile)
		else
			minetest.chat_send_player(target, "---Please specify a name for the itempack")
		end
		return
	end
	-- Delete itempack
	if fields.idel then
		if fields.itemp ~= "Choose itempack" then
			for x,p in pairs(itempacks) do
					if p.name == fields.itemp then
						table.remove(itempacks, x)
					end
			end
			minetest.chat_send_player(target, "---You have deleted itempack " .. fields.itemp)
			-- Save to file
			local itempackfile = io.open(minetest.get_worldpath() .. "/" .. target .. ".itempacks", "w")
			local ipickle
			for _,p in pairs(itempacks) do
				ipickle = '{ name=\"'..p.name..'\", pack={ '
				local frst = true
				for x,s in pairs(p.pack) do
					if frst then
						ipickle = ipickle .. '\"' .. s .. '\"'
						frst = false
					else
						ipickle = ipickle .. ', \"' .. s .. '\"'
					end
				end
				itempackfile:write(ipickle..' }}\n')
			end
			io.close(itempackfile)
		else
			minetest.chat_send_player(target, "---Please select an itempack")
		end
		return
	end
	-- Announce
	if fields.annc then
		if fields.students ~= "Choose students" and fields.msgtxt then
			if fields.students == "All students" then
				cmddef["every_student"].func(target, "announce subject " .. fields.msgtxt)
			else
				cmddef["announce"].func(target, fields.students .. " " .. fields.msgtxt)
			end
			minetest.chat_send_player(target, "---You sent an announcement (" .. fields.msgtxt .. ") to " .. fields.students)
		else
			minetest.chat_send_player(target, "---Please specify student(s) and a message")
		end
		return
	end
	if fields.alph then
		if fields.msgtxt then
			if #fields.msgtxt > 24 then
				minetest.chat_send_player(target, "---Text is too long to alphabetize to your inventory. Try a couple of words at a time")
			else
				cmddef["alphabetize"].func(target, fields.msgtxt)
				minetest.chat_send_player(target, "---You have alphabetized: " .. fields.msgtxt)
			end
		else
			minetest.chat_send_player(target, "---Text is empty. Please type something to message field")
		end
		return
	end
end

local form2_update = function(player, fields)
	local cmddef = minetest.chatcommands
	local target = player:get_player_name()
	if not minetest.check_player_privs(player, { instructor = true}) then
		minetest.chat_send_player(target, "---Forbidden. No instructor privileges.")
		return
	end
	-- Create protected area
	if fields.prot then
		local areaname
		if not fields.aname or fields.aname == "" then
			areaname = "area" .. math.random(100000,999999)
		else
			areaname = fields.aname
		end
		for id, area in pairs(areas.areas) do
			if area.name == areaname then
				minetest.chat_send_player(target, "---Error. Area with this name already exists. Try again.")
				return
			end	
		end	
		if fields.numb ~= "Radius" then
			local center = player:getpos()
			cmddef["area_pos1"].func(target, math.floor(center.x) - fields.numb .. " " .. math.floor(center.y) - fields.numb .. " " .. math.floor(center.z) - fields.numb)
			cmddef["area_pos2"].func(target, math.floor(center.x) + fields.numb .. " " .. math.floor(center.y) + fields.numb .. " " .. math.floor(center.z) + fields.numb)
			if fields.students == "All students" or fields.students == "Choose students" then
				cmddef["set_owner"].func(target, target .. " " .. areaname)
				minetest.chat_send_player(target, "---You created a protected area " .. areaname .. " with radius of " .. fields.numb .. " owned by you")
			else
				cmddef["set_owner"].func(target, fields.students .. " " .. areaname)
				minetest.chat_send_player(target, "---You created a protected area " .. areaname .. " with radius of " .. fields.numb .. " owned by " .. fields.students)
			end
		else
			minetest.chat_send_player(target, "---Please specify radius of the protected area")
		end
		return
	end
	-- Remove protected area
	if fields.rema then
		if not areas then
			minetest.chat_send_player(target, "---Error: No areas defined.")
			return
		end
		if fields.alist == "Area here" then
			local pos = vector.round(player:getpos())
			for id, area in pairs(areas:getAreasAtPos(pos)) do
				areas:remove(id)
				areas:save()
				minetest.chat_send_player(target, "---You removed a protected area " .. area.name .. " owned by " .. area.owner)
			end
		else
			for id, area in pairs(areas.areas) do
				if area.name == fields.alist then
					areas:remove(id)
					areas:save()
					minetest.chat_send_player(target, "---You removed a protected area " .. area.name .. " owned by " .. area.owner)
				end
			end
		end
		return
	end
	-- Open protected area
	if fields.opna then
		if not areas then
			minetest.chat_send_player(target, "---Error: No areas defined.")
			return
		end
		if fields.alist == "Area here" then
			local pos = vector.round(player:getpos())
			for id, area in pairs(areas:getAreasAtPos(pos)) do
				if not areas.areas[id].open then
					areas.areas[id].open = true
					areas:save()
					minetest.chat_send_player(target, "---You opened a protected area " .. area.name .. " owned by " .. area.owner)
				end
			end
		else
			for id, area in pairs(areas.areas) do
				if area.name == fields.alist then
					if not areas.areas[id].open then
						areas.areas[id].open = true
						areas:save()
						minetest.chat_send_player(target, "---You opened a protected area " .. area.name .. " owned by " .. area.owner)
					end
				end
			end
		end
		return
	end
	-- Close protected area
	if fields.clsa then
		if not areas then
			minetest.chat_send_player(target, "---Error: No areas defined.")
			return
		end
		if fields.alist == "Area here" then
			local pos = vector.round(player:getpos())
			for id, area in pairs(areas:getAreasAtPos(pos)) do
				if areas.areas[id].open then
					areas.areas[id].open = nil
					areas:save()
					minetest.chat_send_player(target, "---You closed a protected area " .. area.name .. " owned by " .. area.owner)
				end
			end
		else
			for id, area in pairs(areas.areas) do
				if area.name == fields.alist then
					if areas.areas[id].open then
						areas.areas[id].open = nil
						areas:save()
						minetest.chat_send_player(target, "---You closed a protected area " .. area.name .. " owned by " .. area.owner)
					end
				end
			end
		end
		return
	end
	-- Teleport to a student
	if fields.tele then
		if fields.students ~= "All students" and fields.students ~= "Choose students" then
			cmddef["teleport"].func(target, fields.students)
			minetest.chat_send_player(target, "---You teleported yourself to " .. fields.students)
		else
			minetest.chat_send_player(target, "---Please specify a student")
		end
		return
	end
	-- Teleport to me (bring)
	if fields.brng then
		if fields.students ~= "Choose students" then
			if fields.students == "All students" then
				cmddef["every_student"].func(target, "teleport subject " .. target)
			else
				cmddef["teleport"].func(target, fields.students .. " " .. target)
			end
			minetest.chat_send_player(target, "---You teleported " .. fields.students .. " to yourself")
		else
			minetest.chat_send_player(target, "---Please specify student(s)")
		end
		return
	end
	-- Grant a privilege
	if fields.grnt then
		if fields.students ~= "Choose students" and fields.privs ~= "Choose privilege" then
			if fields.students == "All students" then
				cmddef["every_student"].func(target, "grant subject " .. fields.privs)
			else
				cmddef["grant"].func(target, fields.students .. " " .. fields.privs)
			end
			if fields.privs == "all" then
				minetest.chat_send_player(target, "---You granted all privileges to " .. fields.students)
			else
				minetest.chat_send_player(target, "---You granted the " .. fields.privs .. " privilege to " .. fields.students)
			end
		else
			minetest.chat_send_player(target, "---Please specify student(s) and a privilege")
		end
		return
	end
	-- Revoke a privilege
	if fields.rvok then
		if fields.students ~= "Choose students" and fields.privs ~= "Choose privilege" then
			if fields.students == "All students" then
				cmddef["every_student"].func(target, "revoke subject " .. fields.privs)
			else
				cmddef["revoke"].func(target, fields.students .. " " .. fields.privs)
			end
			if fields.privs == "all" then
				minetest.chat_send_player(target, "---You revoked all privileges from " .. fields.students)
			else
				minetest.chat_send_player(target, "---You revoked the " .. fields.privs .. " privilege from " .. fields.students)
			end
		else
			minetest.chat_send_player(target, "---Please specify student(s) and a privilege")
		end
		return
	end
	-- Invisible
	if fields.invi then
		cmddef["invisible"].func(target)
		return
	end
	-- Create Jailbox
	if fields.jlcr then
		if fields.numb ~= "Radius" then
			cmddef["jailbox_set"].func(target, fields.numb)
		else
			minetest.chat_send_player(target, "---Please specify radius.")
		end
		return
	end
	-- Remove Jailbox
	if fields.jlrm then
		cmddef["jailbox_unset"].func(target)
		return
	end
	-- Set time
	if fields.time then
		cmddef["time"].func(target, fields.time)
		return
	end
end

local student_list = function()
	local entries = "Choose students"
	if minetest.chatcommands["every_student"] then
		entries = entries .. "," .. "All students"
	end
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		if not privs["instructor"] then
			entries = entries .. "," .. name
		end
	end
	return entries
end

local items_list = function(filter)
	local entries = "Choose item"
	local itemnames = {}
	for key, val in pairs(minetest.registered_items) do
		if filter then
			if string.match(key, filter) then
				table.insert(itemnames, key)
			end
		else
			if string.len(key) > 0 then
				table.insert(itemnames, key)
			end
		end
	end
	table.sort(itemnames)
	for i,n in ipairs(itemnames) do
		entries = entries .. "," .. n
	end
	return entries
end

local privs_list = function()
	local entries = "Choose privilege,all"
	for key, val in pairs(minetest.registered_privileges) do
		entries = entries .. "," .. key
	end
	return entries
end

local itempacks_list = function()
	local entries = "Choose itempack"
	for n,p in pairs(itempacks) do
		entries = entries .. "," .. p.name
	end
	return entries
end

local areas_list = function()
	if areas then
		local entries = "Area here"
		for id, area in pairs(areas.areas) do
			entries = entries .. "," .. area.name
		end
		return entries
	end
end

local set_eduformspec = function()
	local eduformspec = "dropdown[0,0.1;4.1;students;" .. student_list() .. ";1]"
	eduformspec = eduformspec .. "field[0.3,2.33;8,1;msgtxt;Message;]"
	eduformspec = eduformspec .. "button[0,3;2,1;mesg;Message]"
	if minetest.chatcommands["announce"] then
		eduformspec = eduformspec .. "button[2,3;2,1;annc;Announce]"
	end
	if minetest.chatcommands["alphabetize"] then
		eduformspec = eduformspec .. "button[4,3;2,1;alph;Alphabetize]"
	end
	if minetest.chatcommands["heal"] then
		eduformspec = eduformspec .. "button[4,0;2,1;hlst;Heal]"
		eduformspec = eduformspec .. "button[6,0;2,1;hlme;Heal me]"
	end
	if minetest.chatcommands["clearinv"] then
		eduformspec = eduformspec .. "button[2,8;2,1;clri;Clear inv]"
		eduformspec = eduformspec .. "button[0,8;2,1;clrm;Clear my inv]"
	end
	--~ if minetest.chatcommands["copyinv"] then
		--~ eduformspec = eduformspec .. "button[4,2;4,1;cpyi;Copy inventory]"
	--~ end
	if minetest.chatcommands["give"] then
		eduformspec = eduformspec .. "dropdown[0,5.1;4.1;items;" .. items_list(edufilter) .. ";1]"
		eduformspec = eduformspec .. "dropdown[4,5.1;3.3;itemp;" .. itempacks_list() .. ";1]"
		eduformspec = eduformspec .. "dropdown[3,6.1;0.8;numb;1,2,3,4,5,6,7,8,9,10,20,30,40,50,100;1]"
		eduformspec = eduformspec .. "field[4.3,6.33;2,1;ipname;Itempack name;]"
		eduformspec = eduformspec .. "field[0.3,6.33;2,1;filtr;Item filter;" .. edufilter .. "]"
		eduformspec = eduformspec .. "button[1.8,6;0.7,1;fltr;F]"
		eduformspec = eduformspec .. "button[2.2,6;0.7,1;fltc;C]"
		eduformspec = eduformspec .. "button[7.1,5;0.9,1;idel;Del]"
		eduformspec = eduformspec .. "button[4,8;2,1;chki;Check inv]"
		eduformspec = eduformspec .. "button[0,7;2,1;gvme;Give me]"
		eduformspec = eduformspec .. "button[2,7;2,1;gvst;Give]"
		eduformspec = eduformspec .. "button[4,7;2,1;ipgv;Give itempack]"
		eduformspec = eduformspec .. "button[6,7;2,1;ipgm;Give me itempack]"
		eduformspec = eduformspec .. "button[6,6;2,1;ipst;Store itempack]"
	end
	if minetest.chatcommands["pulverize"] then
		eduformspec = eduformspec .. "button[6,8;2,1;empt;Destroy item]"
	end
	return eduformspec
end

local set_worldformspec = function()
	local worldformspec = "dropdown[0,0.1;4.1;students;" .. student_list() .. ";1]"
	worldformspec = worldformspec .. "dropdown[0,8.1;4.1;privs;" .. privs_list() .. ";1]"
	worldformspec = worldformspec .. "button[4,8;2,1;grnt;Grant]"
	worldformspec = worldformspec .. "button[6,8;2,1;rvok;Revoke]"
	if minetest.chatcommands["set_owner"] and minetest.chatcommands["area_pos1"] and minetest.chatcommands["area_pos2"] then
		worldformspec = worldformspec .. "dropdown[4,3.1;4.1;alist;" .. areas_list() .. ";1]"
		worldformspec = worldformspec .. "label[4,2.75;Select area]"
		worldformspec = worldformspec .. "button[0,4;2,1;prot;Create area]"
		worldformspec = worldformspec .. "button[2,4;2,1;rema;Remove area]"
		worldformspec = worldformspec .. "button[4,4;2,1;opna;Open area]"
		worldformspec = worldformspec .. "button[6,4;2,1;clsa;Close area]"
		worldformspec = worldformspec .. "field[0.3,3.33;2.9,1;aname;New area name;]"
		worldformspec = worldformspec .. "dropdown[2.7,3.1;1.2;numb;Radius,5,10,20,30,40,50;1]"
	end
	if minetest.chatcommands["time"] then
		worldformspec = worldformspec .. "dropdown[6.5,0.1;1.5;time;Time,00:00,06:00,12:00,18:00;1]"
	end
	if minetest.chatcommands["invisible"] then
		worldformspec = worldformspec .. "button[4,0;2,1;invi;Invisible]"
	end
	if minetest.chatcommands["teleport"] then
		worldformspec = worldformspec .. "button[4,6;2,1;tele;Bring me to]"
		worldformspec = worldformspec .. "button[6,6;2,1;brng;Bring to me]"
	end
	if minetest.chatcommands["freeze"] then
		worldformspec = worldformspec .. "button[0,6;2,1;frze;Freeze]"
	end
	if minetest.chatcommands["unfreeze"] then
		worldformspec = worldformspec .. "button[2,6;2,1;unfr;Unfreeze]"
	end
	if minetest.chatcommands["jailbox_set"] then
		worldformspec = worldformspec .. "button[0,5;2,1;jlcr;Create Jailbox]"
		worldformspec = worldformspec .. "button[2,5;2,1;jlrm;Remove Jailbox]"
	end
	return worldformspec
end

minetest.register_on_joinplayer(function(player)
	load_itempacks(player)
end)

sfinv.register_page("edutest_ui:edu", {
	title = "Edu",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, set_eduformspec(), false)
	end,
	is_in_nav = function(self, player, context)
		return minetest.check_player_privs(player, { instructor = true})
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if minetest.check_player_privs(player, { instructor = true}) then
			form1_update(player, fields)
			sfinv.set_page(player, "edutest_ui:edu")
		end
	end,
})

sfinv.register_page("edutest_ui:world", {
	title = "World",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, set_worldformspec(), false)
	end,
	is_in_nav = function(self, player, context)
		return minetest.check_player_privs(player, { instructor = true})
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if minetest.check_player_privs(player, { instructor = true}) then
			form2_update(player, fields)
			sfinv.set_page(player, "edutest_ui:world")
		end
	end,
})

