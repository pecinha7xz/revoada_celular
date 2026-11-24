local phoneObjects = {}
local animationTimers = {}
local phoneOpen = {}

local function clearAnimation(player, playOutro)
    if isTimer(animationTimers[player]) then
        killTimer(animationTimers[player])
    end
    animationTimers[player] = nil

    if isElement(phoneObjects[player]) then
        destroyElement(phoneObjects[player])
    end
    phoneObjects[player] = nil

    if isElement(player) and playOutro and (getElementHealth(player) or 0) > 0 then
        setPedAnimation(player, config.animacao.grupo, config.animacao.fechar, 50, false, false, false, false)
    end
end

local function startAnimation(player)
    setPedWeaponSlot(player, 0)

    local object = createObject(config.modeloTelefone, 0, 0, 0)
    if isElement(object) then
        phoneObjects[player] = object
        setObjectScale(object, config.escalaTelefone)
        setElementCollisionsEnabled(object, false)
        setElementInterior(object, getElementInterior(player))
        setElementDimension(object, getElementDimension(player))

        local boneResource = getResourceFromName("bone_attach")
        local attached = false

        if boneResource and getResourceState(boneResource) == "running" then
            local ok = pcall(function()
                exports.bone_attach:attachElementToBone(object, player, 12, 0, 0.01, 0.03, -15, 270, -15)
            end)
            attached = ok
        end

        if not attached then
            attachElements(object, player, 0.15, 0.25, 0.1, 0, 90, 90)
        end
    end

    setPedAnimation(player, config.animacao.grupo, config.animacao.abrir, 1000, false, false, false, true)

    animationTimers[player] = setTimer(
        function(target)
            if isElement(target) and phoneOpen[target] then
                setPedAnimationProgress(target, config.animacao.abrir, config.animacao.progresso)
            end
        end,
        config.animacao.intervalo, 0, player
    )
end

local function closePhone(player, instant, notifyClient)
    if not isElement(player) then
        return
    end

    phoneOpen[player] = nil
    clearAnimation(player, not instant)

    if notifyClient then
        triggerClientEvent(player, "RevoadaCelular:close", resourceRoot, instant == true)
    end
end

local function openPhone(player)
    if not isElement(player) or phoneOpen[player] then
        return
    end

    if getElementData(player, "FS:interaction") or (getElementHealth(player) or 0) <= 0 then
        return
    end

    phoneOpen[player] = true
    startAnimation(player)
    triggerClientEvent(player, "RevoadaCelular:open", resourceRoot)
end

local function togglePhone(player)
    if not isElement(player) then
        return
    end

    if phoneOpen[player] then
        closePhone(player, false, true)
    else
        openPhone(player)
    end
end

local function bindPhoneKey(player)
    if not isElement(player) then
        return
    end

    if isGuestAccount(getPlayerAccount(player)) then
        return
    end

    unbindKey(player, config.tecla, config.estado, togglePhone)
    bindKey(player, config.tecla, config.estado, togglePhone)
end

local function unbindPhoneKey(player)
    if isElement(player) then
        unbindKey(player, config.tecla, config.estado, togglePhone)
    end
end

addEvent("RevoadaCelular:requestClose", true)
addEventHandler("RevoadaCelular:requestClose", resourceRoot,
    function()
        local player = client
        if not player or source ~= resourceRoot or not phoneOpen[player] then
            return
        end

        closePhone(player, false, true)
    end
)

addEventHandler("onResourceStart", resourceRoot,
    function()
        for _, player in ipairs(getElementsByType("player")) do
            bindPhoneKey(player)
        end
    end
)

addEventHandler("onPlayerLogin", root,
    function()
        bindPhoneKey(source)
    end
)

addEventHandler("onPlayerLogout", root,
    function()
        closePhone(source, true, true)
        unbindPhoneKey(source)
    end
)

addEventHandler("onPlayerWasted", root,
    function()
        closePhone(source, true, true)
    end
)

addEventHandler("onPlayerQuit", root,
    function()
        phoneOpen[source] = nil
        clearAnimation(source, false)
        animationTimers[source] = nil
        phoneObjects[source] = nil
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        for _, player in ipairs(getElementsByType("player")) do
            unbindPhoneKey(player)
            closePhone(player, true, true)
        end
    end
)
