# Redis Caching Implementation Plan

## 1. Overview
Dokumen ini menjelaskan planning implementasi Redis caching untuk mengurangi latency pada endpoint-endpoint aplikasi. Implementasi menggunakan NestJS dengan strategi cache invalidation untuk menjaga konsistensi data.

## 2. Technology Stack
- **Backend Framework**: NestJS (folder `/backend`)
- **Cache Layer**: Redis
- **Redis Client**: `@nestjs/cache-manager` + `cache-manager-redis-yet`
- **Monitoring**: Custom interceptor untuk tracking cache hit/miss rate

## 3. Redis Setup

### 3.1 Installation
```bash
cd backend
npm install @nestjs/cache-manager cache-manager cache-manager-redis-yet redis
```

### 3.2 Environment Configuration
Tambahkan ke `.env`:
```env
# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0
REDIS_TTL_DEFAULT=300

# Environment specific
NODE_ENV=development
```

### 3.3 Docker Setup (Development)
Tambahkan ke `docker-compose.yml`:
```yaml
services:
  redis:
    image: redis:7-alpine
    container_name: keuangan-redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    command: redis-server --appendonly yes
    restart: unless-stopped

volumes:
  redis-data:
```

### 3.4 Production Setup
- **Cloud Provider**: Gunakan managed Redis (AWS ElastiCache, Google Cloud Memorystore, atau DigitalOcean Managed Redis)
- **Security**: Enable password authentication, TLS/SSL
- **High Availability**: Redis Sentinel atau Redis Cluster untuk production

## 4. NestJS Implementation Architecture

### 4.1 Module Structure
```
backend/src/
├── cache/
│   ├── cache.module.ts
│   ├── cache.service.ts
│   ├── cache.config.ts
│   ├── interceptors/
│   │   ├── cache-monitoring.interceptor.ts
│   │   └── cache-invalidation.interceptor.ts
│   └── decorators/
│       ├── cache-key.decorator.ts
│       └── invalidate-cache.decorator.ts
```

### 4.2 Cache Module Configuration
File: `cache/cache.module.ts`
- Setup CacheModule dengan Redis store
- Konfigurasi global TTL default
- Register monitoring interceptor

### 4.3 Cache Service
File: `cache/cache.service.ts`
Fitur:
- `get(key: string)`: Ambil data dari cache
- `set(key: string, value: any, ttl?: number)`: Set cache dengan optional TTL
- `del(key: string | string[])`: Hapus cache (invalidation)
- `delPattern(pattern: string)`: Hapus cache berdasarkan pattern
- `reset()`: Clear semua cache
- `getStats()`: Ambil statistik cache hit/miss

## 5. Caching Strategy per Endpoint Type

### 5.1 Master Data (TTL: 24 jam / 86400 detik)
Endpoint yang jarang berubah:
- `/api/users` (GET list)
- `/api/users/:id` (GET detail)
- `/api/settings` (GET)
- `/api/lookup/*` (Master data referensi)

**Cache Key Pattern**: `master:{entity}:{id?}:{query?}`
**Invalidation**: Saat CREATE, UPDATE, DELETE pada entity terkait

### 5.2 Transactional Data (TTL: 5 menit / 300 detik)
Endpoint dengan data yang sering berubah:
- `/api/transactions` (GET list)
- `/api/transactions/:id` (GET detail)
- `/api/reports/daily` (GET)

**Cache Key Pattern**: `txn:{entity}:{id?}:{query?}`
**Invalidation**: Saat CREATE, UPDATE, DELETE transaction

### 5.3 Dashboard/Reports (TTL: 15 menit / 900 detik)
Endpoint agregasi dan reporting:
- `/api/dashboard/summary`
- `/api/reports/monthly`
- `/api/analytics/*`

**Cache Key Pattern**: `report:{type}:{period}:{filters?}`
**Invalidation**: Saat ada perubahan data yang mempengaruhi report

### 5.4 Authentication (TTL: 1 jam / 3600 detik)
- `/api/auth/me` (GET current user)
- User permissions/roles

**Cache Key Pattern**: `auth:{userId}:{type}`
**Invalidation**: Saat user logout atau role berubah

### 5.5 No Cache
Endpoint yang tidak perlu di-cache:
- Login/Logout
- File uploads
- Real-time data streams
- OTP/Token generation

## 6. Cache Key Naming Convention

### 6.1 Structure
```
{prefix}:{entity}:{identifier}:{queryHash?}
```

### 6.2 Examples
```
master:users:123                          # User detail ID 123
master:users:list:a1b2c3                  # User list dengan query hash
txn:transactions:list:page1:limit10       # Transaction list dengan pagination
report:dashboard:summary:2024-06          # Dashboard summary bulan Juni 2024
auth:user:456:permissions                 # User 456 permissions
```

### 6.3 Query Hash
Untuk endpoint dengan query parameter kompleks, gunakan hash MD5 dari sorted query string:
```typescript
// Example: ?status=active&sort=name&limit=10
// Hash: md5('limit=10&sort=name&status=active')
```

## 7. Cache Invalidation Strategy

### 7.1 Single Entity Invalidation
Saat UPDATE/DELETE entity tunggal:
```typescript
// Hapus cache entity detail
await cacheService.del(`master:users:${userId}`);
// Hapus cache list (semua variant query)
await cacheService.delPattern(`master:users:list:*`);
```

### 7.2 Cascade Invalidation
Saat perubahan mempengaruhi entity lain:
```typescript
// Example: Update transaction -> invalidate transaction + report
await cacheService.del([
  `txn:transactions:${txnId}`,
  `txn:transactions:list:*`,
  `report:dashboard:*`,
  `report:monthly:*`
]);
```

### 7.3 Event-Based Invalidation
Gunakan EventEmitter untuk decouple invalidation logic:
```typescript
// Service emit event
this.eventEmitter.emit('transaction.created', { id, userId });

// Cache listener handle invalidation
@OnEvent('transaction.created')
handleTransactionCreated(payload) {
  // Invalidate related caches
}
```

## 8. Implementation Steps

### Phase 1: Setup & Configuration (Day 1-2)
1. Install dependencies
2. Setup Docker Redis untuk development
3. Create cache module dan configuration
4. Setup environment variables
5. Test basic cache operations

### Phase 2: Core Implementation (Day 3-5)
1. Implement CacheService dengan semua method
2. Create custom decorators (@CacheKey, @InvalidateCache)
3. Create monitoring interceptor
4. Create cache invalidation interceptor
5. Unit testing untuk cache service

### Phase 3: Integration (Day 6-8)
1. Identifikasi endpoint prioritas tinggi
2. Implement caching pada master data endpoints
3. Implement caching pada transactional endpoints
4. Implement cache invalidation pada mutation endpoints
5. Integration testing

### Phase 4: Monitoring & Optimization (Day 9-10)
1. Setup monitoring dashboard
2. Collect metrics (hit rate, miss rate, latency)
3. Optimize TTL values berdasarkan usage pattern
4. Performance testing dan tuning
5. Documentation

## 9. Monitoring & Logging

### 9.1 Metrics to Track
- **Cache Hit Rate**: `(hits / (hits + misses)) * 100`
- **Cache Miss Rate**: `(misses / (hits + misses)) * 100`
- **Average Response Time**: With cache vs without cache
- **Cache Size**: Memory usage
- **Eviction Count**: Berapa banyak key yang di-evict

### 9.2 Logging Strategy
```typescript
// Log cache operations
logger.debug(`Cache HIT: ${key}`);
logger.debug(`Cache MISS: ${key}`);
logger.debug(`Cache SET: ${key}, TTL: ${ttl}s`);
logger.debug(`Cache DEL: ${key}`);
```

### 9.3 Monitoring Endpoint
Create admin endpoint untuk monitoring:
```
GET /api/admin/cache/stats
GET /api/admin/cache/keys?pattern=*
DELETE /api/admin/cache/clear
```

Response example:
```json
{
  "hits": 15420,
  "misses": 3210,
  "hitRate": 82.76,
  "keys": 1523,
  "memoryUsage": "45.2 MB",
  "uptime": "5d 3h 24m"
}
```

## 10. Testing Strategy

### 10.1 Unit Tests
- Test CacheService methods
- Test cache key generation
- Test TTL expiration
- Test invalidation logic

### 10.2 Integration Tests
- Test endpoint caching behavior
- Test cache invalidation flow
- Test concurrent requests
- Test cache consistency

### 10.3 Performance Tests
- Load test dengan/tanpa cache
- Measure latency improvement
- Test cache under high load
- Test Redis failover scenario

## 11. Rollback Plan

### 11.1 Feature Flag
Implement feature flag untuk enable/disable caching:
```env
CACHE_ENABLED=true
```

### 11.2 Gradual Rollout
1. Enable caching untuk 10% traffic
2. Monitor metrics selama 24 jam
3. Jika stable, scale up to 50%
4. Monitor metrics selama 48 jam
5. Full rollout 100%

### 11.3 Rollback Triggers
Rollback jika:
- Cache hit rate < 30%
- Error rate increase > 5%
- Response time increase (unexpected)
- Redis connection issues

## 12. Security Considerations

### 12.1 Sensitive Data
- Jangan cache data sensitif (password, tokens, PII)
- Jika perlu cache user data, gunakan encryption
- Set TTL pendek untuk auth-related cache

### 12.2 Access Control
- Redis admin commands hanya untuk authorized users
- Monitoring endpoint hanya accessible oleh admin
- Implement rate limiting untuk cache clear operations

## 13. Cost Estimation

### 13.1 Development
- Redis managed service: ~$20-50/month (small instance)
- Development time: ~10 hari (1 developer)

### 13.2 Production
- Redis managed service: ~$100-300/month (tergantung traffic)
- Monitoring tools: Included dalam backend monitoring
- Expected cost savings: Reduced database load = lower RDS cost

### 13.3 Expected Performance Improvement
- Latency reduction: 50-80% untuk cached endpoints
- Database load reduction: 40-60%
- Throughput increase: 2-3x untuk read operations

## 14. Documentation & Handover

### 14.1 Documentation Required
- API documentation update (caching behavior)
- Deployment guide (Redis setup)
- Troubleshooting guide
- Monitoring dashboard guide

### 14.2 Training
- Team training on cache invalidation strategy
- Redis monitoring best practices
- Debugging cache-related issues

## 15. Future Enhancements

### 15.1 Advanced Features
- Cache warming strategy
- Distributed caching (multi-region)
- Cache versioning untuk breaking changes
- Automatic cache invalidation dengan CDC (Change Data Capture)

### 15.2 Alternative Strategies
- Hybrid caching (Redis + In-memory)
- Edge caching dengan CDN
- GraphQL caching dengan persisted queries

## 16. Success Criteria

✅ Cache hit rate > 70% untuk master data  
✅ Latency reduction > 50% untuk cached endpoints  
✅ No data inconsistency issues  
✅ Monitoring dashboard operational  
✅ Zero downtime deployment  
✅ Team trained dan documentation complete  

---

## Appendix A: Useful Redis Commands

```bash
# Connect to Redis
redis-cli

# Check connection
PING

# Get all keys
KEYS *

# Get value
GET key_name

# Delete key
DEL key_name

# Delete by pattern
EVAL "return redis.call('del', unpack(redis.call('keys', ARGV[1])))" 0 pattern:*

# Get TTL
TTL key_name

# Monitor commands
MONITOR

# Get info
INFO
INFO stats

# Flush all data (DANGER!)
FLUSHALL
```

## Appendix B: Reference Links

- NestJS Caching: https://docs.nestjs.com/techniques/caching
- Redis Documentation: https://redis.io/docs/
- Cache-Manager: https://github.com/node-cache-manager/node-cache-manager
- Best Practices: https://redis.io/docs/manual/patterns/

---

**Document Version**: 1.0  
**Last Updated**: 2026-06-29  
**Author**: Development Team  
**Status**: Planning Phase
