local semaphore = require("ngx.semaphore")
local string_format = string.format
local server = require("resty.websocket.server")
local cjson = require("cjson")
local mrandom = math.random
local Client = require("litchi.client")
local Dispather = require("litchi.dispatcher")
math.randomseed(ngx.now())

local context, dispather
local _M = {}

-- init
function _M.init(litchi_context)
    context = litchi_context
    dispather = Dispather:new(context)
end


-- start a new client
function _M.start_client()
    local wb, err = server:new{
        timeout = 3600000, -- s
        max_payload_len = 65535,
    }

    if not wb then
        ngx.log(ngx.ERR, "failed to new websocket: ", err)
        return ngx.exit(444)
    end

    local client_id = mrandom(10000, 99999) -- mock id
    local sema = semaphore.new()
    local client = Client:new(client_id, wb, sema, dispather)
    context.clients[client.id] = client
    client:receive_msg()
    client:send_msg()

    ngx.log(ngx.INFO, string_format("[client][%d] login...", client.id))
end


return _M
