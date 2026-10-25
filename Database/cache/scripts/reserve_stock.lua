-- ============================================================================
-- Redis Lua Script: reserve_stock.lua
-- Atomically checks available stock, decrements inventory, and creates a reservation
--
-- KEYS[1]: stock:available:{sku}
-- KEYS[2]: stock:res:{sku}:{orderId}
-- ARGV[1]: Requested Quantity (Integer)
-- ARGV[2]: Reservation TTL in seconds (e.g., 900 for 15 minutes)
--
-- Returns:
--  1  -> Success: Stock reserved
--  0  -> Out of stock / Insufficient quantity
-- -1  -> Key does not exist
-- ============================================================================

local stockKey = KEYS[1]
local reservationKey = KEYS[2]
local requestedQty = tonumber(ARGV[1])
local reservationTtl = tonumber(ARGV[2])

-- 1. Check if stock key exists
local currentStock = redis.call('GET', stockKey)
if not currentStock then
    return -1
end

currentStock = tonumber(currentStock)

-- 2. Verify sufficient stock
if currentStock < requestedQty then
    return 0 -- Insufficient inventory
end

-- 3. Atomic deduction and reservation assignment
redis.call('DECRBY', stockKey, requestedQty)
redis.call('SETEX', reservationKey, reservationTtl, tostring(requestedQty))

return 1 -- Successfully reserved
