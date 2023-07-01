--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------
local easing = require("easing")

--------------------------------------------------------------------------
--[[ Gmoosespawner class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)
	assert(TheWorld.ismastersim, "Gmoosespawner should not exist on client")

	local _worldsettingstimer = TheWorld.components.worldsettingstimer
	local UM_STORM_TIMERNAME = "um_snowstorm_timer"
	local UM_STOPSTORM_TIMERNAME = "um_stopsnowstorm_timer"

	--------------------------------------------------------------------------
	--[[ Private constants ]]
	--------------------------------------------------------------------------


	--------------------------------------------------------------------------
	--[[ Public Member Variables ]]
	--------------------------------------------------------------------------

	self.inst = inst

	--------------------------------------------------------------------------
	--[[ Private Member Variables ]]
	--------------------------------------------------------------------------

	local _storming = false
	local _spawninterval = TUNING.TOTAL_DAY_TIME * 3
	local _despawninterval = TUNING.TOTAL_DAY_TIME / 2

	--------------------------------------------------------------------------
	--[[ Private member functions ]]
	--------------------------------------------------------------------------

	local function StopStorming()
		print("StopStorming")
		_storming = false

		TheWorld:RemoveTag("snowstormstart")

		if TheWorld.net ~= nil then
			TheWorld.net:RemoveTag("snowstormstartnet")
		end

		if _worldsettingstimer:GetTimeLeft(UM_STORM_TIMERNAME) == nil then
			_worldsettingstimer:StartTimer(UM_STORM_TIMERNAME, _spawninterval + math.random(0, 120))
		end

		_worldsettingstimer:ResumeTimer(UM_STORM_TIMERNAME)
	end

	local function StartStorming()
		print("StartStorming")
		_storming = true

		for i, v in ipairs(AllPlayers) do
			--if v.components ~= nil and v.components.talker ~= nil and TheWorld.state.cycles >= TUNING.DSTU.WEATHERHAZARD_START_DATE_WINTER then
			v.components.talker:Say(GetString(v, "ANNOUNCE_SNOWSTORM"))
			--end
		end

		TheWorld:PushEvent("ms_forceprecipitation", true)

		TheWorld:DoTaskInTime(60, function()
			print("TASK IN TIME STORM START!")
			TheWorld:AddTag("snowstormstart")
			if TheWorld.net ~= nil then
				TheWorld.net:AddTag("snowstormstartnet")
			end

			if _worldsettingstimer:GetTimeLeft(UM_STOPSTORM_TIMERNAME) == nil then
				_worldsettingstimer:StartTimer(UM_STOPSTORM_TIMERNAME, _despawninterval + math.random(80, 120))
			end

			_worldsettingstimer:ResumeTimer(UM_STOPSTORM_TIMERNAME)
		end)
	end

	local function StartStorms()
		print("StartStorms")
		if _worldsettingstimer:GetTimeLeft(UM_STORM_TIMERNAME) == nil then
			_worldsettingstimer:StartTimer(UM_STORM_TIMERNAME, _spawninterval + math.random(0, 120))
		end

		_worldsettingstimer:ResumeTimer(UM_STORM_TIMERNAME)
	end

	local function StopStorms()
		print("StopStorms")
		_worldsettingstimer:StopTimer(UM_STORM_TIMERNAME)
		_worldsettingstimer:StopTimer(UM_STOPSTORM_TIMERNAME)
	end

	--------------------------------------------------------------------------
	--[[ Private event handlers ]]
	--------------------------------------------------------------------------

	local function OnSeasonChange(self)
		if TheWorld.state.season == "winter" then
			if TheWorld.state.cycles >= TUNING.DSTU.WEATHERHAZARD_START_DATE_WINTER then
				if not _storming then
					print("season change _storming")
					StartStorms()
				end
			end
		else
			print("season change not winter")
			StopStorms()
		end
	end

	function self:OnSave()
		local data =
		{
			storming = _storming,
		}

		return data
	end

	function self:OnLoad(data)
		_storming = data.storming or false

		if _storming then
			print("load _storming start storm")
			TheWorld:AddTag("snowstormstart")
			if TheWorld.net ~= nil then
				TheWorld.net:AddTag("snowstormstartnet")
			end

			if _worldsettingstimer:GetTimeLeft(UM_STOPSTORM_TIMERNAME) == nil then
				_worldsettingstimer:StartTimer(UM_STOPSTORM_TIMERNAME, _despawninterval + math.random(80, 120))
			end

			_worldsettingstimer:ResumeTimer(UM_STOPSTORM_TIMERNAME)
		end
	end

	function self:OnPostInit()
		_worldsettingstimer:AddTimer(UM_STORM_TIMERNAME, _spawninterval + math.random(0, 120), true, StartStorming)
		_worldsettingstimer:AddTimer(UM_STOPSTORM_TIMERNAME, _despawninterval + math.random(80, 120), true, StopStorming)

		OnSeasonChange()
	end

	self:WatchWorldState("season", OnSeasonChange)
	--self.inst:ListenForEvent("forcetornado", PickAttackTarget)
end)