local screenW, screenH = guiGetScreenSize()
local scale = math.min(screenW / 1366, screenH / 768)
local offsetX = (screenW - 1366 * scale) / 2
local offsetY = (screenH - 768 * scale) / 2

local function px(value)
    return offsetX + value * scale
end

local function py(value)
    return offsetY + value * scale
end

local function sz(value)
    return value * scale
end

local phone = {
    active = false,
    closing = false,
    started = 0,
    closeTimer = nil
}

local baseTexture = dxCreateTexture("Files/Imagens/Base.png", "argb", true, "clamp")
local phoneFontElement = dxCreateFont("Files/font.ttf", math.max(8, math.floor(10 * scale)), false, "cleartype")
local phoneFont = phoneFontElement or "default-bold"

local wallpaperSVG
if type(svgCreate) == "function" then
    wallpaperSVG = svgCreate(460, 992, [[
        <svg xmlns="http://www.w3.org/2000/svg" width="460" height="992" viewBox="0 0 460 992">
            <defs>
                <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
                    <stop offset="0%" stop-color="#11101B"/>
                    <stop offset="52%" stop-color="#090911"/>
                    <stop offset="100%" stop-color="#171020"/>
                </linearGradient>
                <linearGradient id="purple" x1="0" y1="0" x2="1" y2="1">
                    <stop offset="0%" stop-color="#D8B4FE"/>
                    <stop offset="52%" stop-color="#A020F0"/>
                    <stop offset="100%" stop-color="#7020B8"/>
                </linearGradient>
                <radialGradient id="glowTop" cx="85%" cy="12%" r="70%">
                    <stop offset="0%" stop-color="#A020F0" stop-opacity=".42"/>
                    <stop offset="100%" stop-color="#A020F0" stop-opacity="0"/>
                </radialGradient>
                <radialGradient id="glowBottom" cx="8%" cy="92%" r="72%">
                    <stop offset="0%" stop-color="#7020B8" stop-opacity=".34"/>
                    <stop offset="100%" stop-color="#7020B8" stop-opacity="0"/>
                </radialGradient>
            </defs>
            <rect width="460" height="992" rx="42" fill="url(#bg)"/>
            <rect width="460" height="992" rx="42" fill="url(#glowTop)"/>
            <rect width="460" height="992" rx="42" fill="url(#glowBottom)"/>
            <path d="M-35 360 C105 270 178 310 265 220 S415 85 515 120" fill="none" stroke="#A020F0" stroke-opacity=".19" stroke-width="2"/>
            <path d="M-60 710 C70 610 155 650 235 560 S390 450 510 490" fill="none" stroke="#B66BFA" stroke-opacity=".13" stroke-width="2"/>
            <circle cx="385" cy="185" r="116" fill="none" stroke="#A020F0" stroke-opacity=".12" stroke-width="2"/>
            <circle cx="70" cy="765" r="155" fill="none" stroke="#A020F0" stroke-opacity=".10" stroke-width="2"/>
            <path d="M55 305 H405" stroke="#A020F0" stroke-opacity=".30" stroke-width="2"/>
            <text x="230" y="230" text-anchor="middle" fill="#FFFFFF" font-family="Arial, sans-serif" font-size="42" font-weight="700" letter-spacing="6">REVOADA</text>
            <text x="230" y="278" text-anchor="middle" fill="url(#purple)" font-family="Arial, sans-serif" font-size="30" font-weight="700" letter-spacing="12">CITY</text>
            <text x="230" y="315" text-anchor="middle" fill="#D8D1E2" fill-opacity=".72" font-family="Arial, sans-serif" font-size="12" letter-spacing="4">SUA CIDADE CONECTADA</text>
            <path d="M40 875 H420" stroke="#A020F0" stroke-opacity=".2" stroke-width="2"/>
        </svg>
    ]])
end

local apps = {
    {"WhatsApp", "Files/Imagens/Icons/whatsapp.png"},
    {"Contatos", "Files/Imagens/Icons/contatos.png"},
    {"GPS", "Files/Imagens/Icons/gps.png"},
    {"Câmera", "Files/Imagens/Icons/camera.png"},
    {"Banco", "Files/Imagens/Icons/banco.png"},
    {"Spotify", "Files/Imagens/Icons/spotify.png"},
    {"Calculadora", "Files/Imagens/Icons/calculadora.png"},
    {"Notas", "Files/Imagens/Icons/Notas.png"},
    {"Veículos", "Files/Imagens/Icons/vehicles.png"},
    {"Config.", "Files/Imagens/Icons/config.png"},
    {"JBL", "Files/Imagens/Icons/jbl.png"},
    {"Aplicativos", "Files/Imagens/Icons/App.png"}
}

for _, app in ipairs(apps) do
    app.texture = dxCreateTexture(app[2], "argb", true, "clamp")
end

local dockIcons = {
    dxCreateTexture("Files/Imagens/Icons/telefone.png", "argb", true, "clamp"),
    dxCreateTexture("Files/Imagens/Icons/whatsapp.png", "argb", true, "clamp"),
    dxCreateTexture("Files/Imagens/Icons/contatos.png", "argb", true, "clamp")
}

local function drawStatus(alpha, offset)
    local hour, minute = getTime()
    local timeText = string.format("%02d:%02d", hour or 12, minute or 0)

    dxDrawText(timeText, px(1105), py(246 + offset), px(1165), py(265),
        tocolor(245, 242, 250, alpha), 1, phoneFont, "left", "center", false, false, false, false, false)

    dxDrawText("REVOADA", px(1220), py(246), px(1288), py(265),
        tocolor(214, 190, 238, alpha), 1, phoneFont, "right", "center", false, false, false, false, false)

    dxDrawRectangle(px(1292), py(252 + offset), sz(17), sz(8), tocolor(235, 230, 245, alpha * 0.75), false)
    dxDrawRectangle(px(1294), py(254 + offset), sz(12), sz(4), tocolor(160, 32, 240, alpha), false)
    dxDrawRectangle(px(1309), py(254), sz(2), sz(4), tocolor(235, 230, 245, alpha * 0.75), false)
end

local function drawApps(alpha, offset)
    for index, app in ipairs(apps) do
        local column = (index - 1) % 4
        local line = math.floor((index - 1) / 4)

        local iconX = 1102 + column * 53
        local iconY = 365 + line * 88
        local iconSize = 36

        dxDrawRectangle(px(iconX - 4), py(iconY - 4 + offset), sz(44), sz(44),
            tocolor(160, 32, 240, alpha * 0.16), false)

        if app.texture and isElement(app.texture) then
            dxDrawImage(px(iconX), py(iconY + offset), sz(iconSize), sz(iconSize),
                app.texture, 0, 0, 0, tocolor(255, 255, 255, alpha), false)
        end

        dxDrawText(app[1], px(iconX - 7), py(iconY + 40 + offset), px(iconX + 43), py(iconY + 55),
            tocolor(240, 236, 248, alpha), 1, phoneFont, "center", "top", false, false, false, false, false)
    end

    dxDrawRectangle(px(1104), py(654 + offset), sz(198), sz(62),
        tocolor(10, 8, 18, alpha * 0.84), false)

    for index, texture in ipairs(dockIcons) do
        local iconX = 1120 + (index - 1) * 61
        if texture and isElement(texture) then
            dxDrawImage(px(iconX), py(665 + offset), sz(39), sz(39),
                texture, 0, 0, 0, tocolor(255, 255, 255, alpha), false)
        end
    end
end

local function renderPhone()
    if not phone.active then
        return
    end

    local progress = math.min(1, (getTickCount() - phone.started) / 550)
    local alpha = phone.closing and (1 - progress) * 255 or progress * 255
    local offset = phone.closing and (-progress * 12) or ((1 - progress) * 12)
    local phoneY = 226 + offset
    local screenY = 236 + offset

    if baseTexture and isElement(baseTexture) then
        dxDrawImage(px(1083), py(phoneY), sz(255), sz(518),
            baseTexture, 0, 0, 0, tocolor(255, 255, 255, alpha), false)
    else
        dxDrawRectangle(px(1083), py(phoneY), sz(255), sz(518),
            tocolor(20, 20, 25, alpha), false)
    end

    if wallpaperSVG and isElement(wallpaperSVG) then
        dxDrawImage(px(1094.5), py(screenY), sz(228.5), sz(495.1),
            wallpaperSVG, 0, 0, 0, tocolor(255, 255, 255, alpha), false)
    else
        dxDrawRectangle(px(1094.5), py(screenY), sz(228.5), sz(495.1),
            tocolor(11, 10, 18, alpha), false)
        dxDrawText("REVOADA CITY", px(1100), py(screenY + 58), px(1317), py(screenY + 110),
            tocolor(160, 32, 240, alpha), 1.2, phoneFont, "center", "center", false, false, false, false, false)
    end

    drawStatus(alpha, offset)
    drawApps(alpha, offset)
end

local function finishClose()
    if isTimer(phone.closeTimer) then
        killTimer(phone.closeTimer)
    end

    phone.closeTimer = nil
    phone.active = false
    phone.closing = false
    removeEventHandler("onClientRender", root, renderPhone)
    showCursor(false)
end

local function closePhone(instant)
    if not phone.active then
        return
    end

    if instant then
        finishClose()
        return
    end

    if phone.closing then
        return
    end

    phone.closing = true
    phone.started = getTickCount()
    playSound("Files/Sons/fechando_celular.mp3", false)
    showCursor(false)

    phone.closeTimer = setTimer(finishClose, 550, 1)
end

addEvent("RevoadaCelular:open", true)
addEventHandler("RevoadaCelular:open", resourceRoot,
    function()
        if phone.closeTimer and isTimer(phone.closeTimer) then
            killTimer(phone.closeTimer)
        end

        phone.active = true
        phone.closing = false
        phone.started = getTickCount()

        if not isEventHandlerAdded or not isEventHandlerAdded("onClientRender", root, renderPhone) then
            addEventHandler("onClientRender", root, renderPhone)
        end

        showCursor(false)
        playSound("Files/Sons/abrindo_celular.mp3", false)
    end
)

addEvent("RevoadaCelular:close", true)
addEventHandler("RevoadaCelular:close", resourceRoot,
    function(instant)
        closePhone(instant == true)
    end
)

addEventHandler("onClientKey", root,
    function(key, press)
        if key == "escape" and press and phone.active then
            cancelEvent()
            triggerServerEvent("RevoadaCelular:requestClose", resourceRoot)
        end
    end
)

addEventHandler("onClientPlayerWasted", localPlayer,
    function()
        closePhone(true)
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if isTimer(phone.closeTimer) then
            killTimer(phone.closeTimer)
        end

        if phone.active then
            removeEventHandler("onClientRender", root, renderPhone)
        end

        showCursor(false)

        if baseTexture and isElement(baseTexture) then
            destroyElement(baseTexture)
        end

        if wallpaperSVG and isElement(wallpaperSVG) then
            destroyElement(wallpaperSVG)
        end

        if phoneFontElement and isElement(phoneFontElement) then
            destroyElement(phoneFontElement)
        end

        for _, app in ipairs(apps) do
            if app.texture and isElement(app.texture) then
                destroyElement(app.texture)
            end
        end

        for _, texture in ipairs(dockIcons) do
            if texture and isElement(texture) then
                destroyElement(texture)
            end
        end
    end
)
