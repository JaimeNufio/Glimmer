local assets =
{
    Asset("ANIM", "anim/glimmer_fuel.zip"),
	Asset("ATLAS", "images/inventoryimages/glimmerfuel.xml"),
    Asset("IMAGE", "images/inventoryimages/glimmerfuel.tex"),
}

local foldername = KnownModIndex:GetModActualName("Glimmer and Family DST")
local rec = GetModConfigData("rtype", foldername)

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("glommer_fuel")
    inst.AnimState:SetBuild("glimmer_fuel")
    inst.AnimState:PlayAnimation("idle")

    --MakeDragonflyBait(inst, 3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	--[[
	inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	]]
	
    inst:AddComponent("inspectable")  
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/glimmerfuel.xml"
  
    inst:AddComponent("stackable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL/2

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
	
	--[[
    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.GLOMMERFUEL_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.GLOMMERFUEL_SOILCYCLES
	]]
	
    MakeHauntableLaunch(inst)

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 5*(rec/2) --TUNING.HEALING_TINY
    inst.components.edible.hungervalue = -5*(rec/2)  --TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = 5*(rec/2) --TUNING.SANITY_MED

    return inst
end

return Prefab("glimmerfuel", fn, assets)