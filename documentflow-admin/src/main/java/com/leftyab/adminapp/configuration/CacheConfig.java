package com.leftyab.adminapp.configuration;

/*
@Configuration
public class CacheConfig {

  private int initialCapacity = 100;
  private int maximumSize = 500;
  private int expireAfterAccess = 5;
  private TimeUnit expireTimeUnit = TimeUnit.MINUTES;

  private String specAsString = "initialCapacity=100,maximumSize=500,expireAfterAccess=5m,recordStats";

  @Bean
  public CacheManager cacheManager() {
    CaffeineCacheManager cacheManager = new CaffeineCacheManager();//("AIRCRAFTS", "SECOND_CACHE");
    cacheManager.setAllowNullValues(false);
    //can happen if you get a value from a @Cachable that returns null
    //cacheManager.setCacheSpecification(specAsString);
    //cacheManager.setCaffeineSpec(caffeineSpec());
    cacheManager.setCaffeine(caffeineCacheBuilder());
    return cacheManager;
  }

  CaffeineSpec caffeineSpec() {
    return CaffeineSpec.parse(specAsString);
  }

  Caffeine<Object, Object> caffeineCacheBuilder() {
    return Caffeine.newBuilder()
      .initialCapacity(initialCapacity)
      .maximumSize(maximumSize)
      .expireAfterWrite(expireAfterAccess, expireTimeUnit)
      .weakKeys()
      .removalListener(new CustomRemovalListener())
      .recordStats();
  }

  static class CustomRemovalListener implements RemovalListener<Object, Object> {
    @Override
    public void onRemoval(Object key, Object value, RemovalCause cause) {
      System.out.format("removal listerner called with key [%s], cause [%s], evicted [%S]\n", key, cause.toString(), cause.wasEvicted());
    }
  }
}
*/
