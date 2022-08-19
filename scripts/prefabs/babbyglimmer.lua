local assets =
{
    Asset("ANIM", "anim/glimmer.zip"),
}

local prefabs =
{
    "glimmerfuel",
    "glimmerwings",
    "monstermeat",
}

local brain = require("brains/glommerbrain")

local foldername = KnownModIndex:GetModActualName("Glimmer and Family DST")
local gcap = GetModConfigData("gcap", foldername)
local speed = GetModConfigData("speed", foldername)
local rec = GetModConfigData("rtype", foldername)
local rdrop = GetModConfigData("rdrop", foldername)

SetSharedLootTable('babbyglimmer',
{
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
--  {'glimmerwings',            1.00},
    {'glimmerfuel',             1.00},
    {'glimmerfuel',             1.00},
})

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    --print(inst, "ShouldSleep", DefaultSleepTest(inst), not inst.sg:HasStateTag("open"), inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
    return DefaultSleepTest(inst) 
    and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) 
    and not TheWorld.state.isfullmoon
end

local function LeaveWorld(inst)
    inst:Remove()
end

local function OnEntitySleep(inst)
    if inst.ShouldLeaveWorld then
        LeaveWorld(inst)
    end
end

local function OnSave(inst, data)
    data.ShouldLeaveWorld = inst.ShouldLeaveWorld
end

local function OnLoad(inst, data)
    if data then
        inst.ShouldLeaveWorld = data.ShouldLeaveWorld
    end
end

local function OnSpawnFuel(inst, fuel)
    inst.sg:GoToState("goo", fuel)
end

local function OnStopFollowing(inst)
    --print("glimmer - OnStopFollowing")
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
    --print("glimmer - OnStartFollowing")
    if (inst.components.follower.leader:HasTag("glimmerflower")) then 
        inst:AddTag("companion")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, .75)
    inst.Transform:SetFourFaced()

    MakeGhostPhysics(inst, 1, .5)

    inst.MiniMapEntity:SetIcon("glommer.png")
    inst.MiniMapEntity:SetPriority(5)

    inst.AnimState:SetBank("glommer")
    inst.AnimState:SetBuild("glimmer")
    inst.AnimState:PlayAnimation("idle_loop")

    inst:AddTag("babbyglimmer")
    inst:AddTag("babby")
    inst:AddTag("flying")
    inst:AddTag("cattoyairborne")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst:AddComponent("knownlocations")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('babbyglimmer') 

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY/5

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetOnSpawnFn(OnSpawnFuel)
    inst.components.periodicspawner.prefab = "glimmerfuel"
    inst.components.periodicspawner.basetime = 3 * rdrop * TUNING.TOTAL_DAY_TIME / 12
    inst.components.periodicspawner.randtime = 3 * rdrop * TUNING.TOTAL_DAY_TIME * 2
    inst.components.periodicspawner:Start()

    inst:SetBrain(brain)
    inst:SetStateGraph("SGglommer")

    MakeMediumFreezableCharacter(inst, "glimmer_body")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnEntitySleep = OnEntitySleep

    MakeHauntablePanic(inst)

	local s = .6
	inst.Transform:SetScale(s,s,s)
	
    return inst
end

return Prefab("common/creatures/babbyglimmer", fn, assets, prefabs)
