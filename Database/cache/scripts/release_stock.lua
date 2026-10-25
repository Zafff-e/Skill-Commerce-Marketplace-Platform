-- ============================================================================
-- Redis Lua Script: release_stock.lua
-- Atomically cancels an active reservation and restores inventory to available pool
--
-- KEYS[1]: stock:available:{sku}
-- KEYS[2]: stock:res:{sku}:{orderId}
--
-- Returns:
--  1 -> Successfully released and credited back
--  0 -> Reservation key did not exist (already released or expired)
-- ============================================================================

local stockKey = KEYS[1]
local reservationKey = KEYS[2]

local reservedQty = redis.call('GET', reservationKey)
if not reservedQty then
    return 0 -- No active reservation found
end

reservedQty = tonumber(reservedQty)

-- 1. Restore inventory
redis.call('INCRBY', stockKey, reservedQty)

-- 2. Remove reservation key
redis.call('DEL', reservationKey)

return 1
