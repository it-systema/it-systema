package com.leftyab.documentflow.mainapp.configuration;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.web.context.annotation.RequestScope;
/*
@Configuration
@EnableTransactionManagement
@EntityScan({"rgc.budgeting.**", "datamodel.**", "budgeting.**"})
public class DataSourceConfig { //extends DefaultDataSourceConfiguration {

  @Autowired
  private Environment environment;
  public DataSourceConfig() {
//    super(environment);
  }
  @RequestScope
  @Bean(name = "entityManager")
//  @DependsOn({"entityManagerFactory"})
  public EntityManager getEntityManager(EntityManagerFactory entityManagerFactory) {
    return entityManagerFactory.createEntityManager();
  }

  @RequestScope
  @Bean(name = "coreDataService")
  public IDataService getDataService() {
    return new CoreDataService();
  }
}
*/
