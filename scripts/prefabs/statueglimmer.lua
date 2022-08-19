local assets =
{
    Asset("ANIM", "anim/glimmer_statue.zip"),
    Asset("ANIM", "anim/glimmer_swap_flower.zip"),
}

local prefabs =
{
    "glimmer",
    "glimmerflower",
    "marble",
}

SetSharedLootTable('statueglimmer',
{
    {'marble',  1.00},
    {'marble',  1.00},
    {'marble',  1.00},
    --{'bell_blueprint', 1.00}, -- Biigfoot probably won't work with multi-player, says Graham.
})

local LIGHT_FRAMES = 6

local function PushLight(inst)
    inst.Light:SetRadius(Lerp(0, .75, inst.lightval:value() / LIGHT_FRAMES))
    if TheWorld.ismastersim then
        inst.Light:Enable(inst.lightval:value() > 0)
    end
end

local function OnUpdateLight(inst, dframes)
    if inst.islighton:value() then
        if inst.lightval:value() < LIGHT_FRAMES then
            inst.lightval:set_local(inst.lightval:value() + dframes)
        elseif inst.lighttask ~= nil then
            inst.lighttask:Cancel()
            inst.lighttask = nil
        end
    elseif inst.lightval:value() > 0 then
        inst.lightval:set_local(inst.lightval:value() - dframes)
    elseif inst.lighttask ~= nil then
        inst.lighttask:Cancel()
        inst.lighttask = nil
    end

    PushLight(inst)
end

local function OnLightDirty(inst)
    if inst.lighttask == nil then
        inst.lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end

local function OnMakeEmpty(inst)
    inst.AnimState:ClearOverrideSymbol("swap_flower")
    inst.AnimState:Hide("swap_flower")
    if inst.islighton:value() then
        inst.islighton:set(false)
        OnLightDirty(inst)
    end
end

local function OnMakeFull(inst)
    inst.AnimState:OverrideSymbol("swap_flower", "glimmer_swap_flower", "swap_flower")
    inst.AnimState:Show("swap_flower")
end

local function SpawnGlommer(inst)
    --Get spawn point
    local x, y, z = inst.Transform:GetWorldPosition()
    local spawn_pt = Vector3(x, y, z)
    local theta = math.random() * 2 * PI
    local offset = FindWalkableOffset(spawn_pt, theta, 35, 12, true)
    if offset ~= nil then
        spawn_pt.x = spawn_pt.x + offset.x
        spawn_pt.y = spawn_pt.y + offset.y
        spawn_pt.z = spawn_pt.z + offset.z
    end

    local glimmer = SpawnPrefab("glimmer")
    if glimmer ~= nil then
        if glimmer.components.follower.leader ~= inst then
            glimmer.components.follower:SetLeader(inst)
        end
        glimmer.Physics:Teleport(spawn_pt:Get())
        glimmer:FacePoint(x, y, z)
        return glimmer
    end
end

local function SpawnGland(inst)
    if inst.components.pickable.canbepicked then
        --already has a flower on the shelf
        --double check light, because this path is really for loading
        if not inst.islighton:value() then
            inst.islighton:set(true)
            OnLightDirty(inst)
        end
        return
    elseif inst.components.timer:TimerExists("Cooldown") then
        --picked recently
        return
    end

    local gland = TheSim:FindFirstEntityWithTag("glimmerflower")
    if gland ~= nil then
        return
    end

    if not inst.islighton:value() then
        inst.islighton:set(true)
        OnLightDirty(inst)
    end

    local glimmer = TheSim:FindFirstEntityWithTag("glimmer") or SpawnGlommer(inst)
    if glimmer ~= nil then
        glimmer.ShouldLeaveWorld = false
    end

    inst.components.pickable:Regen()
end

local function RemoveGland(inst)
    inst.components.pickable:MakeEmpty()

    local gland = TheSim:FindFirstEntityWithTag("glimmerflower")
    if gland == nil then
        local glimmer = TheSim:FindFirstEntityWithTag("glimmer")
        if glimmer ~= nil then
            glimmer.ShouldLeaveWorld = true
        end
    end
end

local function OnIsFullmoon(inst, isfullmoon)
    if not isfullmoon then
        RemoveGland(inst)
    else
        SpawnGland(inst)
    end
end

local function OnInit(inst)
    inst:WatchWorldState("isfullmoon", OnIsFullmoon)
	OnIsFullmoon(inst, TheWorld.state.isfullmoon)
    if inst.islighton:value() then
        --Finish the light tween immediately for loading
        inst.lightval:set(LIGHT_FRAMES)
        OnLightDirty(inst)
    end
end

local function OnLoseChild(inst)
    inst.components.pickable:MakeEmpty()
end

local function OnPicked(inst, picker, loot)
    local glimmer = TheSim:FindFirstEntityWithTag("glimmer")
    if glimmer ~= nil and glimmer.components.follower.leader ~= loot then
        glimmer.components.follower:StopFollowing()
        glimmer.components.follower:SetLeader(loot)
    end

    inst.components.timer:StartTimer("Cooldown", TUNING.TOTAL_DAY_TIME * 3)
end

local function OnWorked(inst, worker, workleft)
    if workleft <= 0 then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
        inst.components.lootdropper:DropLoot(inst:GetPosition())
        inst.AnimState:PlayAnimation("low")
        inst:RemoveComponent("workable")
        inst:RemoveComponent("lootdropper")
    else
        inst.AnimState:PlayAnimation(workleft < TUNING.ROCKS_MINE * .5 and "med" or "full")
    end
end

local function OnSave(inst, data)
    data.worked = inst.components.workable == nil or nil
end

local function OnLoad(inst, data)
    if data ~= nil and data.worked and inst.components.workable ~= nil then
        inst.AnimState:PlayAnimation("low")
        inst:RemoveComponent("workable")
        inst:RemoveComponent("lootdropper")
    end
end

local function OnLoadWorked(inst)
    if inst.components.workable ~= nil then
        if inst.components.workable.workleft <= 0 then
            inst.AnimState:PlayAnimation("low")
            inst:RemoveComponent("workable")
            inst:RemoveComponent("lootdropper")
        else
            inst.AnimState:PlayAnimation(inst.components.workable.workleft < TUNING.ROCKS_MINE * .5 and "med" or "full")
        end
    end
end

local function getstatus(inst)
    return inst.components.workable == nil and "EMPTY" or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .75)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("statue_glommer.png")

    inst.AnimState:SetBank("glommer_statue")
    inst.AnimState:SetBuild("glimmer_statue")
    inst.AnimState:PlayAnimation("full")

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(0.9)
    inst.Light:SetFalloff(0.3)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst.lightval = net_tinybyte(inst.GUID, "statueglimmer.lightval", "lightdirty")
    inst.islighton = net_bool(inst.GUID, "statueglimmer.islighton", "lightdirty")
    inst.lighttask = nil

    inst.entity:AddTag("statue")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("timer")
    inst:AddComponent("leader")
    inst.components.leader.onremovefollower = OnLoseChild

    inst:AddComponent("pickable")
    inst.components.pickable.product = "glimmerflower"
    inst.components.pickable:SetOnPickedFn(OnPicked)
    inst.components.pickable:SetMakeEmptyFn(OnMakeEmpty)
    inst.components.pickable.makefullfn = OnMakeFull

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable.savestate = true
    inst.components.workable:SetOnLoadFn(OnLoadWorked)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("statueglimmer")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:DoTaskInTime(0, OnInit)

    MakeHauntableWork(inst)

    return inst
end

return Prefab("statueglimmer", fn, assets, prefabs),
		MakePlacer( "common/statueglimmer_placer", "glommer_statue", "glimmer_statue", "full" ) 

