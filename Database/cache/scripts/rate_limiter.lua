-- ============================================================================
-- Redis Lua Script: rate_limiter.lua
-- Sliding window rate limiter based on Redis Sorted Sets (ZSet)
--
-- KEYS[1]: ratelimit:{ip}:{action}
-- ARGV[1]: Current Timestamp in milliseconds (e.g., 1761400000000)
-- ARGV[2]: Window size in milliseconds (e.g., 60000 for 1 minute)
-- ARGV[3]: Maximum permitted requests within the window
--
-- Returns:
--  1 -> Request allowed
--  0 -> Rate limit exceeded
-- ============================================================================

local rateLimitKey = KEYS[1]
local nowMs = tonumber(ARGV[1])
local windowMs = tonumber(ARGV[2])
local maxRequests = tonumber(ARGV[3])

local clearBefore = nowMs - windowMs

-- 1. Remove entries outside the sliding window
redis.call('ZREMRANGEBYSCORE', rateLimitKey, '-inf', clearBefore)

-- 2. Count current entries in window
local currentCount = redis.call('ZCARD', rateLimitKey)

if currentCount < maxRequests then
    -- Record this request with unique timestamp as score and member
    redis.call('ZADD', rateLimitKey, nowMs, tostring(nowMs) .. ':' .. tostring(math.random(1000, 9999)))
    -- Set TTL to match window duration
    redis.call('PEXPIRE', rateLimitKey, windowMs)
    return 1
else
    return 0 -- Rate limited
end
