local assets =
{
    Asset("ANIM", "anim/meat_rack_food.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBuild("raindrop")
    inst.AnimState:SetBank("raindrop")
	inst.AnimState:PlayAnimation("anim")

	inst.AnimState:SetMultColour(0.5, 1, 0, 1)

    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

	inst:DoTaskInTime(0, function()
		local x, y, z = inst.Transform:GetWorldPosition()
		SpawnPrefab("acid_rain_splash_hiss").Transform:SetPosition(x,0,z)
	end)
	
	
	inst:ListenForEvent("animover", inst.Remove)
	
    return inst
end

local function fnhiss()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBuild("flies")
    inst.AnimState:SetBank("flies")
	inst.AnimState:PlayAnimation("flies_puff")

	inst.AnimState:SetMultColour(0.5, 1, 0, 1)
	inst.Transform:SetScale(0.4,0.4,0.4)

    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end
	
    inst.SoundEmitter:PlaySound("UCSounds/AcidBurn/AcidBurn", "acidhiss")
    inst.SoundEmitter:SetVolume("acidhiss", .2)
	
	inst:ListenForEvent("animover", inst.Remove)
	
    return inst
end

return Prefab("acid_rain_splash", fn),--, assets)
		Prefab("acid_rain_splash_hiss", fnhiss)