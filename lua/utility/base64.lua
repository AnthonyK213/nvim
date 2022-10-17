-- From: https://github.com/toastdriven/lua-base64/blob/master/base64.lua

local M = {}
local lib = require("utility.lib")
local index_table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function to_binary(integer)
    local remaining = tonumber(integer)
    local bin_bits = ""

    for i = 7, 0, -1 do
        local current_power = 2 ^ i

        if remaining >= current_power then
            bin_bits = bin_bits .. "1"
            remaining = remaining - current_power
        else
            bin_bits = bin_bits .. "0"
        end
    end

    return bin_bits
end

local function from_binary(bin_bits)
    return tonumber(bin_bits, 2)
end

---Encode `str` to base64 code.
---(`new_work` invocable)
---@param str string String to encode.
---@return string Encoded string.
function M.encode(str)
    local bit_pattern = ""
    local encoded = ""
    local trailing = ""

    for i = 1, string.len(str) do
        bit_pattern = bit_pattern .. to_binary(string.byte(string.sub(str, i, i)))
    end

    -- Check the number of bytes. If it"s not evenly divisible by three,
    -- zero-pad the ending & append on the correct number of ``=``s.
    if string.len(bit_pattern) % 3 == 2 then
        trailing = "=="
        bit_pattern = bit_pattern .. "0000000000000000"
    elseif string.len(bit_pattern) % 3 == 1 then
        trailing = "="
        bit_pattern = bit_pattern .. "00000000"
    end

    for i = 1, string.len(bit_pattern), 6 do
        local byte = string.sub(bit_pattern, i, i + 5)
        local offset = tonumber(from_binary(byte))
        encoded = encoded .. string.sub(index_table, offset + 1, offset + 1)
    end

    return string.sub(encoded, 1, -1 - string.len(trailing)) .. trailing
end

---Decode base64 code.
---(`new_work` invocable)
---@param str string Base64 code.
---@return string? Decoded string.
function M.decode(str)
    local padded = str:gsub("%s", "")
    local unpadded = padded:gsub("=", "")
    local bit_pattern = ""
    local decoded = ""

    for i = 1, string.len(unpadded) do
        local char = string.sub(str, i, i)
        local offset, _ = string.find(index_table, char)
        if offset == nil then
            lib.notify_err("Invalid character \"" .. char .. "\" found.")
            return nil
        end

        bit_pattern = bit_pattern .. string.sub(to_binary(offset - 1), 3)
    end

    for i = 1, string.len(bit_pattern), 8 do
        local byte = string.sub(bit_pattern, i, i + 7)
        decoded = decoded .. string.char(from_binary(byte))
    end

    local padding_length = padded:len() - unpadded:len()

    if (padding_length == 1 or padding_length == 2) then
        decoded = decoded:sub(1, -2)
    end

    return decoded
end

return M
