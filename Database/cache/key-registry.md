# Redis Key Taxonomy & Cache Registry

**Platform:** SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)  
**Target Cache Engine:** Redis 7.2 (In-Memory Data Store)  
**Eviction Policy:** `volatile-lru` (Evict keys with TTL under memory pressure)  
**Max Memory Cap:** 512MB  

---

## 1. Key Namespaces & Operational Policies

| Namespace | Key Pattern | Data Structure | Default TTL | Business Purpose & Invalidation Rule |
| :--- | :--- | :--- | :--- | :--- |
| **Guest Carts** | `cart:guest:{sessionId}` | Hash | 7 Days (604800s) | Stores items added before authentication. Merged into user cart upon login/signup. |
| **User Carts** | `cart:user:{userId}` | Hash | 30 Days | Persistent shopping cart across browser and MAUI mobile app. |
| **Real-Time Stock** | `stock:available:{sku}` | String (Integer) | Persistent | Fast atomic decrements during checkout prior to relational ledger commit. |
| **Stock Reservations** | `stock:res:{sku}:{orderId}` | String | 15 Minutes (900s) | Holds reserved inventory during payment processing; auto-expires if unpaid. |
| **Distributed Locks** | `lock:sku:{sku}` | String (Token) | 5 Seconds | Short-lived mutex preventing race conditions on stock adjustments (`SET NX EX 5`). |
| **User Sessions** | `session:auth:{userId}:{tokenId}` | Hash | 7 Days | Validates active logins; deleted upon logout or remote revocation. |
| **Token Blacklist** | `token:revoked:{jti}` | String | Token Expire | Stores invalidated JWT identifiers until their natural expiration. |
| **API Rate Limits** | `ratelimit:{ip}:{action}` | Sorted Set (ZSet) | 60 Seconds | Sliding window rate limiting protecting emergency booking endpoints from spam. |
| **Technician Geo** | `geo:providers:active` | GeoSet (GEO) | 24 Hours | Real-time coordinates of available technicians updated via SignalR. |
| **Category Cache** | `cache:categories:tree` | String (JSON) | 1 Hour | High-frequency catalog navigation read cache. |

---

## 2. Cart Data Schema in Redis

For keys `cart:user:{userId}` and `cart:guest:{sessionId}`:
- **Field:** `{sku}` (e.g., `CAP-AC-45UF`)
- **Value:** JSON string:
```json
{
  "sku": "CAP-AC-45UF",
  "title": "SHIZUKI 45uF CBB65 Dual Run Motor Capacitor",
  "unitPrice": 650.00,
  "quantity": 2,
  "isPreOrder": false,
  "addedAt": "2026-10-25T15:00:00Z"
}
```

---

## 3. Atomic Concurrency Scripts

All mission-critical checkout reservations must be executed exclusively via the atomic Lua scripts inside [`cache/scripts/`](file:///e:/Zafir_Hasan/Project_SkillCommerce/DataBase/cache/scripts/):
1. **`reserve_stock.lua`**: Tests stock sufficiency and decrements available units atomically in 1 round-trip.
2. **`release_stock.lua`**: Re-credits inventory back to the available pool when reservations cancel or expire.
3. **`rate_limiter.lua`**: Sliding window rate limiter for emergency service dispatches.
