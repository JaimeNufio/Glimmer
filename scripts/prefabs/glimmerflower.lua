local assets =
{
    Asset("ANIM", "anim/glimmer_flower.zip"),
	Asset("ATLAS", "images/inventoryimages/glimmerflower.xml"),
    Asset("IMAGE", "images/inventoryimages/glimmerflower.tex"),
}

local prefabs =
{
    "glimmer",
}

local foldername = KnownModIndex:GetModActualName("Glimmer and Family DST")
local gcap = GetModConfigData("gcap", foldername)
local speed = GetModConfigData("speed", foldername)

local function OnLoseChild(inst, child)
    if not inst:HasTag("glimmerflower") then
        return
    end

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst:AddTag("show_spoilage")
    --inst.components.inventoryitem:ChangeImageName("glimmerflower_dead")
    inst.AnimState:PlayAnimation("idle_dead")
    inst:RemoveTag("glimmerflower")

    --V2C: I think this is trying to refresh the inventory tile
    --     because show_spoilage doesn't refresh automatically.
    --     Plz document hacks like this in the future -_ -""
    if inst.components.inventoryitem:IsHeld() then
        local owner = inst.components.inventoryitem.owner
        inst.components.inventoryitem:RemoveFromOwner(true)
        if owner.components.container ~= nil then
            owner.components.container:GiveItem(inst)
        elseif owner.components.inventory ~= nil then
            owner.components.inventory:GiveItem(inst)
        end
    end

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeDragonflyBait(inst, 3)
	inst.Spawning = nil
end

local function getstatus(inst)
    return not inst:HasTag("glimmerflower") and "DEAD" or nil
end

local function OnPreLoad(inst, data)
    if data ~= nil and data.deadchild then
        OnLoseChild(inst)
    end
end

local function OnSave(inst, data)
    data.deadchild = not inst:HasTag("glimmerflower") or nil
end

local function BabyCrazy(inst)
	print("can we spawn?")
    local pos = Vector3(inst.Transform:GetWorldPosition())
	local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 7, { "glommer" }, {"glimmer","babby"}, {"glommer"})
  --local ents = TheSim:FindEntities(x,y,z, radius, musttags, canttags, mustoneoftags)	
	local theta = math.random() * 2 * PI
    local radius = math.random(1, 3)

	if (#ents ~= 0) then
		print("There are "..#ents.." glommer in range")
		if inst.count <= 10 then
		print("there is space for a baby")
		inst.count = inst.count+1
			if math.random() >= .49 then
				local babbyglimmer = SpawnPrefab("babbyglimmer")
				if babbyglimmer then
					print("babby is real")
					babbyglimmer.Transform:SetPosition(pos:Get())
					SpawnPrefab("splash_ocean").Transform:SetPosition(pos:Get())
					babbyglimmer.components.follower:SetLeader(inst)
				end	
			else
				local babbyglommer = SpawnPrefab("babbyglommer")
				if babbyglommer then
					print("babby is real")
					babbyglommer.Transform:SetPosition(pos:Get())
					SpawnPrefab("collapse_small").Transform:SetPosition(pos:Get())
					babbyglommer.components.follower:SetLeader(inst)
				end	
			end
		else
		print("too many buggities!")
		end
	else
	print("no glommer")
	end
end
	
local function OnInit(inst)
    if inst:HasTag("glimmerflower") then
        --Rebind Glommer
        local glimmer = TheSim:FindFirstEntityWithTag("glimmer")
        if glimmer ~= nil and
            glimmer.components.health ~= nil and
            not glimmer.components.health:IsDead() and
            glimmer.components.follower.leader ~= inst then
            glimmer.components.follower:SetLeader(inst)
			--TUNING.TOTAL_DAY_TIME/20
			inst.Spawning = inst:DoPeriodicTask(TUNING.TOTAL_DAY_TIME*speed,BabyCrazy(inst))
        end
    end
end

local function fn()
    local inst = CreateEntity()
	inst.count = 0
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("glommer_flower")
    inst.AnimState:SetBuild("glimmer_flower")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("glimmerflower")
    inst:AddTag("nonpotatable")
    inst:AddTag("irreplaceable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("leader")
    inst.components.leader.onremovefollower = OnLoseChild
	
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("glimmerflower")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/glimmerflower.xml"
    

    MakeHauntableLaunch(inst)

    inst.OnPreLoad = OnPreLoad
    inst.OnSave = OnSave
	
    inst:DoTaskInTime(0, OnInit)
	--TUNING.TOTAL_DAY_TIME/20
	
	inst.Spawning = inst:DoPeriodicTask(TUNING.TOTAL_DAY_TIME*1,function()BabyCrazy(inst)end)
    return inst
end

return Prefab("common/inventory/glimmerflower", fn, assets, prefabs)
