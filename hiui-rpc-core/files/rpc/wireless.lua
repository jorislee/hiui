local M = {}

local iwinfo = require 'iwinfo'
local ubus = require 'ubus'
local uci = require 'uci'
local json = require 'cjson'
local fs = require 'hiui.fs'

function M.status()
    local devs = {}

    local conn = ubus.connect()
    local status = conn:call('network.wireless', 'status', {}) or {}
    conn:close()

    for dev_name, dev in pairs(status) do
        if dev.up then
            local typ = iwinfo.type(dev_name)
            if not typ then return end

            local iw = iwinfo[typ]

            devs[dev_name] = {
                type = typ,
                channel = iw.channel(dev_name),
                bitrate = iw.bitrate(dev_name)
            }

            local interfaces = {}

            for _, ifs in ipairs(dev.interfaces) do
                local ifname = ifs.ifname
                interfaces[#interfaces + 1] = {
                    ifname = ifname,
                    ssid = iw.ssid(ifname),
                    mode = iw.mode(ifname),
                    bssid = iw.bssid(ifname),
                    encryption = iw.encryption(ifname)
                }
            end

            devs[dev_name].interfaces = interfaces
        end
    end

    return {devs = devs}
end

function M.stations(param)
    local conn = ubus.connect()
    local status = conn:call('network.wireless', 'status', {}) or {}
    conn:close()

    local stations = {}

    for dev_name, dev in pairs(status) do
        if dev.up then
            local typ = iwinfo.type(dev_name)
            if not typ then break end

            local iw = iwinfo[typ]

            local band = dev.config.band

            local interfaces = {}

            for _, ifs in ipairs(dev.interfaces) do
                local ifname = ifs.ifname
                local assoclist = iw.assoclist(ifname)

                for macaddr, sta in pairs(assoclist) do
                    stations[#stations + 1] = {
                        macaddr = macaddr,
                        ifname = ifname,
                        band = band,
                        signal = sta.signal,
                        noise = sta.noise,
                        rx_rate = {
                            rate = sta.rx_rate,
                            mhz = sta.rx_mhz,
                            mcs = sta.rx_mcs,
                            ht = sta.rx_ht,
                            vht = sta.rx_vht,
                            he = sta.rx_he,
                            nss = sta.rx_nss,
                            short_gi = sta.rx_short_gi,
                            he_gi = sta.rx_he_gi,
                            he_dcm = sta.rx_he_dcm
                        },
                        tx_rate = {
                            rate = sta.tx_rate,
                            mhz = sta.tx_mhz,
                            mcs = sta.tx_mcs,
                            ht = sta.tx_ht,
                            vht = sta.tx_vht,
                            he = sta.tx_he,
                            nss = sta.tx_nss,
                            short_gi = sta.tx_short_gi,
                            he_gi = sta.tx_he_gi,
                            he_dcm = sta.tx_he_dcm
                        }
                    }
                end
            end
        end
    end

    return {stations = stations}
end

function M.relayInfo()
    local c = uci.cursor()
    local interface = c:get("wireless", "sta", "network")
    local status = {}
    if interface then
        local conn = ubus.connect()
        status = conn:call('network.interface.' .. interface, 'status', {}) or
                     {}
        conn:close()
        status.name = c:get("wireless", "sta", "ssid")
        status.device = c:get("wireless", "sta", "device")
        status.disabled = c:get("wireless", "sta", "disabled")
    end

    return status
end

function M.disRelaydConnect()
    local c = uci.cursor()
    c:set("wireless", "sta", "disabled", "1")
    c:commit("wireless")
    os.execute("wifi reload")
end

local function encryptions(hwtype)
    local wifi_features = {
        "eap", "11n", "11ac", "11r", "acs", "sae", "owe", "suiteb192", "wep",
        "wps"
    }
    local hostapd = {}
    local wpasupplicant = {}
    local result = {}
    result[1] = 'none'
    if hwtype == 'mac80211' or hwtype == 'qcawificfg80211' then
        if fs.access("/usr/sbin/hostapd") or
            fs.access("/usr/sbin/wpa_supplicant") then
            -- result['psk'] = 'WPA-PSK'
            -- result['psk2'] = 'WPA2-PSK'
            -- result['psk-mixed'] = 'WPA-PSK/WPA2-PSK Mixed Mode'
            result[#result + 1] = 'psk'
            result[#result + 1] = 'psk2'
            result[#result + 1] = 'psk-mixed'
            -- for _, feature in ipairs(wifi_features) do
            --     hostapd[feature] = (os.execute(string.format(
            --                                        "/usr/sbin/hostapd -v%s >/dev/null 2>/dev/null",
            --                                        feature)) == 0)
            -- end
            -- for _, feature in ipairs(wifi_features) do
            --     wpasupplicant[feature] =
            --         (os.execute(string.format(
            --                         "/usr/sbin/wpa_supplicant -v%s >/dev/null 2>/dev/null",
            --                         feature)) == 0)
            -- end
            result[#result + 1] = 'sae'
            result[#result + 1] = 'sae-mixed'
        end

        -- if hostapd['sae'] or wpasupplicant['sae'] then
        -- result['sae'] = 'WPA3-SAE'
        -- result['sae-mixed'] = 'WPA2-PSK/WPA3-SAE Mixed Mode'
        -- end
    elseif hwtype == 'broadcom' then
        result[#result + 1] = 'psk'
        result[#result + 1] = 'psk+psk2'
        result[#result + 1] = 'psk2'
        result[#result + 1] = 'wep-open'
        result[#result + 1] = 'wep-shared'
    end

    return result
end

local function glinetApi(item, url)
    local http = require("socket.http")
    local ltn12 = require("ltn12")
    local _f, err = io.popen("basename /tmp/gl_token* |awk -F'_' '{print $3}'")
    if not _f then return nil, err end
    local token = _f:read()
    _f:close()
    local request_body = {}
    local response_body = {}
    http.request({
        url = url,
        method = "POST",
        headers = {Authorization = token},
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body)
    })
    local result = json.decode(table.concat(response_body))
    return {result = result}
end

local function getInfo(func, name)
    local driver_type = iwinfo.type(name)
    if driver_type and iwinfo[driver_type][func] then
        return iwinfo[driver_type][func](name)
    end
    return nil
end

function M.getConfig()
    -- if fs.access('/www/cgi-bin/api') then
    --     return glinetApi({}, "http://127.0.0.1/cgi-bin/api/ap/config")
    -- end
    local c = uci.cursor()
    local result = {}
    c:foreach("wireless", "wifi-device", function(s)
        local htmodelist = getInfo("htmodelist", s[".name"])
        local freqlist = getInfo("freqlist", s[".name"])
        local hwmodelist = getInfo("hwmodelist", s[".name"])
        local txpwrlist = getInfo("txpwrlist", s[".name"])
        s.htmodelist = {}
        if htmodelist then
            for key, value in pairs(htmodelist) do
                if value then table.insert(s.htmodelist, key) end
            end
        end
        s.channels = {}
        if freqlist then
            for key, value in pairs(freqlist) do
                if not value.restricted then
                    table.insert(s.channels, value.channel)
                end
            end
        end
        s.hwmodelist = {}
        if hwmodelist then
            for key, value in pairs(hwmodelist) do
                if value then
                    table.insert(s.hwmodelist, "802.11" .. key)
                end
            end
        end

        s.interfaces = {}
        c:foreach("wireless", "wifi-iface", function(res)
            if res.device == s[".name"] and res['.name'] ~= "sta" then
                if res.hidden and res.hidden == "1" then
                    res.hidden = true
                else
                    res.hidden = false
                end
                if res.disabled and res.disabled == "1" then
                    res.enable = false
                else
                    res.enable = true
                end
                res.encrypt = res.encryption
                table.insert(s.interfaces, res)
            end
        end)
        s.txpwrlist = txpwrlist
        s.encryptions = encryptions(s.type)
        s.device = s[".name"]

        if string.lower(s.band) == "2g" then
            result["wifi_2g"] = s
        elseif string.lower(s.band) == "5g" then
            result["wifi_5g"] = s
        end
    end)
    return result
end

function M.updateConfig(item)
    -- if fs.access('/www/cgi-bin/api') then
    --     return glinetApi(item, "http://127.0.0.1/cgi-bin/api/ap/config")
    -- end
    local c = uci.cursor()
    if item.ssid then c:set('wireless', item.id, 'ssid', item.ssid) end
    if item.encrypt then
        c:set('wireless', item.id, 'encryption', item.encrypt)
    end
    if item.key then c:set('wireless', item.id, 'key', item.key) end
    if item.hidden then c:set('wireless', item.id, 'hidden', item.hidden) end
    if item.channel then
        c:set('wireless', item.device, 'channel', item.channel)
    end
    if item.htmode then c:set('wireless', item.device, 'htmode', item.htmode) end
    if item.txpower then
        if item.txpower == 0 then
            c:delete('wireless', item.device, 'txpower')
        else
            c:set('wireless', item.device, 'txpower', item.txpower)
        end
    end

    if item.disabled then
        c:set('wireless', item.id, 'disabled', item.disabled)
    end
    c:commit('wireless')
    os.execute('wifi reload')
    return {code = 0}
end

return M
