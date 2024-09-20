package com.leftyab.camundaapp;

import org.camunda.bpm.spring.boot.starter.annotation.EnableProcessApplication;
import org.springframework.boot.Banner;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;

//@EnableWebSecurity
@SpringBootApplication(
//  scanBasePackages = {"rgc.budgeting.**", "services.**", "configuration.**"},
//  exclude =  { /*DataSourceAutoConfiguration.class, DataSourceTransactionManagerAutoConfiguration.class, HibernateJpaAutoConfiguration.class*/ }
)
@EnableProcessApplication
public class MainApplication {
/*
  public static void main(String[] args) {
    System.out.println("Hello world!");
  }
*/
  public static void main(String[] args) {

//    testPackageScan();
    new SpringApplicationBuilder()
      .bannerMode(Banner.Mode.CONSOLE)
      .sources(MainApplication.class)
      .run(args);
  }
}
