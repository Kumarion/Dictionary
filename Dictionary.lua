local HttpService = game:GetService("HttpService");
local RandomNew = Random.new();

local DictionaryHelper = { };
DictionaryHelper.__index = DictionaryHelper;
local Changed = Instance.new("BindableEvent");

function DictionaryHelper.new()
	local t = {};
	setmetatable(t, DictionaryHelper);

	local mt = getmetatable(t);

	mt.__newindex = function(self, key, value)
		rawset(self, key, value);
		Changed:Fire(key, value);
	end;

	mt.__index = function(self, key)		
		-- impossible to detect changes on already made variables unfortunately
		-- for table helper functions
		if (rawget(DictionaryHelper, key)) then
			return DictionaryHelper[key];
		end;

		local value = rawget(self, key)
		Changed:Fire(key, value);
		return value;
	end;

	return t;
end

function DictionaryHelper:Watch(callback)
	-- this feature is limited atm
	-- Luau doesnt support the __index for our data that has already been indexed
	-- apparently said it will never be supported for performance issues
	-- oh well
	-- only limited to listening for new changes within the table created
	return Changed.Event;
end

function DictionaryHelper:GetSize()
	local size = 0;

	for _ in pairs(self) do
		size += 1;
	end;

	return size;
end

function DictionaryHelper:Each(callback)
	for index, value in pairs(self) do 
		callback(index, value);
	end;
end

function DictionaryHelper:Keys()
	local keys = { };

	for index, _ in pairs(self) do 
		table.insert(keys, index);
	end;

	return keys;
end

function DictionaryHelper:Values()
	local values = { };

	for _, val in pairs(self) do 
		table.insert(values, val);
	end;

	return values;
end

function DictionaryHelper:Find(Callback, ReturnIndex)
	local tabValue;

	for index, value in pairs(self) do 
		local Result = Callback(index, value);

		if not Result then 
			continue;
		end;

		tabValue = ReturnIndex and index or value;
		break;
	end;

	return tabValue;
end

function DictionaryHelper:Random()
	local size = 0;

	for _ in pairs(self) do
		size += 1;
	end;

	local keys = { };

	for index, _ in pairs(self) do 
		table.insert(keys, index);
	end;

	local RandomIndex = math.random(1, size);
	local PickedValue = keys[RandomIndex];
	return RandomIndex, PickedValue;
end

function DictionaryHelper:FindValue(index)	
	local function deepSearch(val)
		local lookingThrough = if val then val else self;
		
		for key, value in pairs(lookingThrough) do		
			if (rawequal(key, index)) then
				return value;
			end;

			if (typeof(value) == "table") then
				return deepSearch(value);
			end;
		end;
	end;

	return deepSearch();
end

function DictionaryHelper:Map(modifier)
	local map = {content = { }};

	for index, value in pairs(self) do 
		local str = modifier(index, value);
		table.insert(map.content, str);
	end;

	function map.join(separator)
		return table.concat(map.content, separator);
	end;

	-- make more map functions later..?
	return map;
end

function DictionaryHelper:Slice(Offset, Length, Key, Symbol)
	--// Gets a range from A to B of indexs
	--// Converts the dictionary into a sorted dictionary with the given key and then slices it
	local tab = {};
	for i, v in pairs(self) do
		table.insert(tab, {
			i,
			v
		});
	end;
	local newTab = {};

	for index = Offset or 1, Length or #tab do
		table.insert(newTab, tab[index]);
	end;

	local convertedDictionary = {};

	for i, v in pairs(newTab) do
		convertedDictionary[i] = tab[i];
	end;

	--// TODO convert back to a dictionary
	return convertedDictionary;
end

function DictionaryHelper:Filter(Callback)
	--// Filters the self dictionary with the given callback
	local filtered = { };

	for index, value in pairs(self) do 
		local res = Callback(index, value);

		if (not res) then 
			continue;
		end;

		filtered[Index] = Value;
	end;

	return filtered;
end

function DictionaryHelper:Clear()
	for key, value in pairs(self) do
		self[key] = nil;
	end;
end

function DictionaryHelper:Decode(encodedString)
	--// This takes the string they sent in and returns a table
	return HttpService:JSONDecode(encodedString);
end

function DictionaryHelper:Encode()
	--// This takes in the dictionary and sends them back an encoded string
	return HttpService:JSONEncode(self);
end

return DictionaryHelper;
