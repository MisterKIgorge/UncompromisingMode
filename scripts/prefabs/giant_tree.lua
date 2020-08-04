local function makeassetlist(name)
    return {
        Asset("ANIM", "anim/"..name..".zip")
    }
end
SetSharedLootTable( 'um_giant_tree',
{
    {'twigs',           1.0},
    {'twigs',           1.0},
    {'log',   1.0},
    {'log',   1.0},
    {'log',   1.0},
    {'log',   1.0},
})
local function on_chop(inst, chopper, remaining_chops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("turnoftides/common/together/driftwood/chop")
    end

    if remaining_chops > 0 then
        --inst.AnimState:PlayAnimation("chop")
    end
end
local function on_chopped_down(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/appear_wood")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble",nil,.4)
	local pt = inst:GetPosition()
    local theirpos = chopper:GetPosition()
	inst.components.lootdropper:DropLoot()
	inst:RemoveComponent("workable")
	inst.ReadyToChop = false
end

local function Regrow(inst)
	if inst.ReadyToChop == false and inst.RegrowCounter > 10 then
	inst.ReadyToChop = true
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.CHOP)
	inst.components.workable:SetWorkLeft(TUNING.DRIFTWOOD_TREE_CHOPS)
	inst.components.workable:SetOnWorkCallback(on_chop)
	inst.components.workable:SetOnFinishCallback(on_chopped_down)
	inst.RegrowCounter = 0
	end
	if inst.ReadyToChop == false then
	inst.RegrowCounter = inst.RegrowCounter + 1
	end
end

local function onsave(inst, data)
data.ReadyToChop = inst.ReadyToChop
data.RegrowCounter = inst.RegrowCounter
end

local function onload(inst,data)
if data then
inst.ReadyToChop = data.ReadyToChop
inst.RegrowCounter = data.RegrowCounter
else
inst.ReadyToChop = true
inst.RegrowCounter = 0
end
inst:DoPeriodicTask(5,Regrow)
end
--Shadow Spawning Function, for now
local function SpawnTreeShadows(inst)
local x, y, z = inst.Transform:GetWorldPosition()
x = x - 22
z = z - 22
for i = 1, 5 do
for k = 1, 5 do
local shadow = SpawnPrefab("hoodedcanopy")
shadow.Transform:SetPosition(x, y, z)
x = x + 11
end
x = x - 55
z = z + 11
end
end
local function makefn(name, collide)
    return function()
    	local inst = CreateEntity()

    	inst.entity:AddTransform()
    	inst.entity:AddAnimState()
        inst.entity:AddNetwork()
		inst.entity:AddSoundEmitter()
		inst.entity:AddMiniMapEntity()
		inst.entity:AddDynamicShadow()
		inst:AddTag("tree")
		inst.MiniMapEntity:SetIcon("grass.png")
		
        if collide then
            MakeObstaclePhysics(inst, 2.35)
        end

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle", true)
        inst.entity:SetPristine()
		
        if not TheWorld.ismastersim then
            return inst
        end
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.CHOP)
		inst.components.workable:SetWorkLeft(TUNING.DRIFTWOOD_TREE_CHOPS)

		inst.components.workable:SetOnWorkCallback(on_chop)
		inst.components.workable:SetOnFinishCallback(on_chopped_down)
		
		inst:AddComponent("lootdropper")
		inst.components.lootdropper:SetChanceLootTable('um_giant_tree')
		inst:AddComponent("inspectable")
		inst.ReadyToChop = true
		inst.RegrowCounter = 0
		inst:DoPeriodicTask(5,Regrow)
		inst:DoTaskInTime(0,SpawnTreeShadows)
		inst.OnSave = onsave
		inst.OnLoad = onload
        return inst
    end
end

local function pillar(name, collide)
    return Prefab("giant_tree", makefn(name, collide), makeassetlist(name))
end

return pillar("pillar_algae", true)