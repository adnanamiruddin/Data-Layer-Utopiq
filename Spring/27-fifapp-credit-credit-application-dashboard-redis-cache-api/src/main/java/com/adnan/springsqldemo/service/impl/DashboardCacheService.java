package com.adnan.springsqldemo.service.impl;

import com.adnan.springsqldemo.dto.CreditApplicationDashboardResponse;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
public class DashboardCacheService {
  private final RedisTemplate<String, String> redisTemplate;
  private final ObjectMapper objectMapper;
  private final Duration cacheTtl;
  private final String cachePrefix;

  private static final Logger log = LoggerFactory.getLogger(DashboardCacheService.class);

  public DashboardCacheService(RedisTemplate<String, String> redisTemplate, ObjectMapper objectMapper, @Value("${app.redis.dashboard-cache-ttl:60s}") Duration cacheTtl, @Value("${app.redis.dashboard-cache-prefix:dashboard:branch}") String cachePrefix) {
    this.redisTemplate = redisTemplate;
    this.objectMapper = objectMapper;
    this.cacheTtl = cacheTtl;
    this.cachePrefix = cachePrefix;
  }

  public CreditApplicationDashboardResponse get(Long branchId) {
    String key = buildKey(branchId);
    long startTime = System.nanoTime();

    try {
      String cachedJson = redisTemplate.opsForValue().get(key);

      if (cachedJson == null) {
        log.info("[REDIS CACHE MISS] key={} elapsedMs={}", key, elapsedMs(startTime));
        return null;
      }

      CreditApplicationDashboardResponse response = objectMapper.readValue(cachedJson, CreditApplicationDashboardResponse.class);
      log.info("[REDIS CACHE HIT] key={} elapsedMs={}", key, elapsedMs(startTime));
      return response;
    } catch (JsonProcessingException exception) {
      log.warn("[REDIS CACHE INVALID_JSON] key={} action=evict-and-read-from-db message={}", key, exception.getMessage());
      redisTemplate.delete(key);
      return null;
    } catch (RuntimeException exception) {
      log.warn("[REDIS CACHE UNAVAILABLE] key={} action=read-from-db message={}", key, exception.getMessage());
      return null;
    }
  }

  public void put(Long branchId, CreditApplicationDashboardResponse response) {
    String key = buildKey(branchId);
    long startTime = System.nanoTime();

    try {
      String json = objectMapper.writeValueAsString(response);
      redisTemplate.opsForValue().set(key, json, cacheTtl);
      log.info("[REDIS CACHE PUT] key={} ttl={} elapsedMs={}", key, cacheTtl, elapsedMs(startTime));
    } catch (JsonProcessingException exception) {
      throw new IllegalStateException("Failed to serialize dashboard response for Redis cache", exception);
    } catch (RuntimeException exception) {
      log.warn("[REDIS CACHE PUT_FAILED] key={} action=skip-cache message={}", key, exception.getMessage());
    }
  }

  public void evict(Long branchId, String reason) {
    String key = buildKey(branchId);

    try {
      Boolean deleted = redisTemplate.delete(key);
      log.info("[REDIS CACHE EVICT] key={} deleted={} reason={}", key, deleted, reason);
    } catch (RuntimeException exception) {
      log.warn("[REDIS CACHE EVICT_FAILED] key={} reason={} message={}", key, reason, exception.getMessage());
    }
  }

  private String buildKey(Long branchId) {
    return cachePrefix + ":" + branchId;
  }

  private long elapsedMs(long startTime) {
    return Duration.ofNanos(System.nanoTime() - startTime).toMillis();
  }
}
