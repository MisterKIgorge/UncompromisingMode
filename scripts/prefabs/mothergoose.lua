local assets =
{
    Asset("ANIM", "anim/goosemoose_build.zip"),
    Asset("ANIM", "anim/goosemoose_basic.zip"),
    Asset("ANIM", "anim/goosemoose_actions.zip"),
    Asset("ANIM", "anim/goosemoose_yule_build.zip"),
    Asset("SOUND", "sound/goosemoose.fsb"),              -- Why was that commented ?
}

local prefabs =
{
    "mothergooseegg",
    "mothergoose_nesting_ground",
    "mossling",
    "goose_feather",
    "drumstick",
    "chesspiece_moosegoose_sketch",
}

local brain = require("brains/moosebrain")

local MOOSE_SCALE = 1.55

SetSharedLootTable( 'mothergoose',
{
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    --{'drumstick',        1.00},
    --{'drumstick',        1.00},
    {'goose_feather',    1.00},
    {'goose_feather',    1.00},
    {'goose_feather',    1.00},
    {'goose_feather',    1.00},
    {'goose_feather',    1.00},
    {'chesspiece_moosegoose_sketch', 1.00},
	{'oceanfishingbobber_goose_tacklesketch', 1.00},
})

local BASE_TAGS = {"structure"}
local SEE_STRUCTURE_DIST = 20

local TARGET_DIST = 15
local LOSE_TARGET_DIST = 25

local function RetargetFn(inst)
    if inst.sg:HasStateTag("busy") then return end

    local target = nil

    if not target and inst.components.entitytracker:GetEntity("egg") then
        target = FindEntity(inst.components.entitytracker:GetEntity("egg"), TARGET_DIST, function(guy)
                return inst.components.combat:CanTarget(guy)
            end,
            nil,
            { "prey", "smallcreature", "mossling", "moose", "webbedcreature" })
    end

    if not target then
        target =  FindEntity(inst, TARGET_DIST, function(guy)
                return inst.components.combat:CanTarget(guy)
            end,
            nil,
            { "prey", "smallcreature", "mossling", "moose", "webbedcreature" })
    end
	
    if not target then
        target =  FindEntity(inst, TARGET_DIST + 5, function(guy)
                return inst.components.combat:CanTarget(guy)
            end,
            { "structure" },
            { "prey", "smallcreature", "mossling", "moose", "webbedcreature" })
    end

    return target
end

local function KeepTargetFn(inst, target)
    local landing = inst.components.knownlocations:GetLocation("landpoint") or inst:GetPosition()

    return inst.components.combat:CanTarget(target) 
    and inst:GetPosition():Dist(target:GetPosition()) <= LOSE_TARGET_DIST 
    and target:GetPosition():Dist(landing) <= LOSE_TARGET_DIST

end

local function OnEntitySleep(inst)
    if inst.shouldGoAway then
        TheWorld:PushEvent("storehasslergmoose", inst)
        inst:Remove()
    end
end

local function OnSpringChange(inst, isSpring)
    inst.shouldGoAway = not isSpring or TheWorld:HasTag("cave")
    if inst:IsAsleep() then
        OnEntitySleep(inst)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local function OnCollide(inst, other)
    --Destroy?
end

local function OnSave(inst, data)
    data.WantsToLayEgg = inst.WantsToLayEgg
    data.CanDisarm = inst.CanDisarm
    data.shouldGoAway = inst.shouldGoAway
end

local function OnLoad(inst, data)
    if data.WantsToLayEgg then
        inst.WantsToLayEgg = data.WantsToLayEgg
    end
    if data.CanDisarm then
        inst.CanDisarm = data.CanDisarm
    end
    inst.shouldGoAway = data.shouldGoAway or false
end

local function ontimerdone(inst, data)
    if data.name == "WantsToLayEgg" then
        inst.WantsToLayEgg = true
    end

    if data.name == "DisarmCooldown" then
        inst.CanDisarm = true
    end

    if data.name == "TornadoAttack" then
        inst.TornadoAttack = true
    end
end

local function rename(inst)
    inst.components.named:PickNewName()
end

local function OnPreLoad(inst, data)
	local x, y, z = inst.Transform:GetWorldPosition()
	if y > 0 then
		inst.Transform:SetPosition(x, 0, z)
	end
end

local function OnDead(inst)
    TheWorld:PushEvent("mothergoosekilled", inst)
    AwardRadialAchievement("moosegoose_killed", inst:GetPosition(), TUNING.ACHIEVEMENT_RADIUS_FOR_GIANT_KILL)

	local loot = SpawnPrefab("bigbird_meat")
	if loot ~= nil then
		inst.components.lootdropper:SpawnLootPrefab("bigbird_meat")
		inst.components.lootdropper:SpawnLootPrefab("bigbird_meat")
	else
		inst.components.lootdropper:SpawnLootPrefab("drumstick")
		inst.components.lootdropper:SpawnLootPrefab("drumstick")
	end
end

local function OnRemove(inst)
	if inst.iamflyingaway == nil then
		TheWorld:PushEvent("mothergooseremoved", inst)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    local s = MOOSE_SCALE
    inst.Transform:SetScale(s,s,s)
    inst.Transform:SetFourFaced()

    inst.DynamicShadow:SetSize(6, 2.75)

    MakeGiantCharacterPhysics(inst, 5000, 1)

    inst.Physics:SetCollisionCallback(OnCollide)

    inst.AnimState:SetBank("goosemoose")
    inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "goosemoose_build" or "goosemoose_yule_build")
    inst.AnimState:PlayAnimation("idle", true)

    ------------------------------------------

    inst:AddTag("moose")
    inst:AddTag("mothergoose")
    inst:AddTag("epic")
    inst:AddTag("animal")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    ------------------

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10, 15)

    ------------------

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(7000 * TUNING.DSTU.MOTHER_GOOSE_HEALTH)
    inst.components.health.destroytime = 3

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.MOOSE_DAMAGE)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.MOOSE_ATTACK_RANGE)
    inst.components.combat.hiteffectsymbol = "goosemoose_body"
    inst.components.combat:SetAttackPeriod(TUNING.MOOSE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/moose/hurt")

    ------------------------------------------

    inst:AddComponent("explosiveresist")

    ------------------------------------------

    inst:AddComponent("sleeper")
    inst.shouldGoAway = false

    ------------------------------------------

    inst:AddComponent("lootdropper")
	
	inst.components.lootdropper:SetChanceLootTable('mothergoose')

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("named")
    inst.components.named.possiblenames = {STRINGS.NAMES["MOTHERGOOSE1"], STRINGS.NAMES["MOTHERGOOSE2"]}
    inst.components.named:PickNewName()
    inst:DoPeriodicTask(5, rename)

    ------------------------------------------

    inst:AddComponent("knownlocations")
    inst:AddComponent("inventory")
    inst:AddComponent("entitytracker")
    inst:AddComponent("timer")
    inst:AddComponent("drownable")

    ------------------------------------------

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.MOOSE }, { FOODGROUP.MOOSE })
    inst.components.eater.eatwholestack = true
	
	
    if TUNING.DSTU.VETCURSE ~= "off" then
        inst:AddComponent("vetcurselootdropper")
	    inst.components.vetcurselootdropper.loot = "feather_frock"
    end
    ------------------------------------------

    inst:WatchWorldState("isspring", OnSpringChange)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("entitysleep", OnEntitySleep)

    ------------------------------------------

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeHugeFreezableCharacter(inst, "goosemoose_body")

    inst:ListenForEvent("timerdone", ontimerdone)
    inst:ListenForEvent("EggHatch", ontimerdone)

    inst.WantsToLayEgg = false
    inst.CanDisarm = false

    inst.OnPreLoad = OnPreLoad

    ------------------------------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.MOOSE_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.MOOSE_RUN_SPEED

	inst:ListenForEvent("death", OnDead)
    inst:ListenForEvent("onremove", OnRemove)

    inst:SetStateGraph("SGmothermoose")
    inst:SetBrain(brain)

    return inst
end

return Prefab("mothergoose", fn, assets, prefabs)
