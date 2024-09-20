package com.leftyab.adminapp.configuration;
/*

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.web.context.annotation.RequestScope;
import services.common.dao.CoreDataService;
import services.common.dao.IDataService;

@Configuration
@EnableTransactionManagement
@EntityScan({"rgc.budgeting.**", "datamodel.**", "budgeting.**"})
public class DataSourceConfig {
  @Autowired
  private Environment environment;

  public DataSourceConfig() {

  }

  @RequestScope
  @Bean(name = "entityManager")
//  @DependsOn({"entityManagerFactory"})
  public EntityManager getEntityManager(*/
/*LocalContainerEntityManagerFactoryBean*//*
EntityManagerFactory entityManagerFactory) {
//    return super.getEntityManager(entityManagerFactory);
    return entityManagerFactory.createEntityManager();
  }

//  @RequestScope
  @Bean(name = "coreDataService")
  public IDataService getDataService() {
    return new CoreDataService();
  }
}
*/
