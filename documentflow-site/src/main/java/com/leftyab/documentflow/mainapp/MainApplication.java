package com.leftyab.documentflow.mainapp;

import com.leftyab.core.actions.services.ActionsManager;
import com.leftyab.spring.configuration.AppActionsProperties;
import jakarta.annotation.PostConstruct;
import org.springframework.boot.Banner;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

@EnableWebSecurity
@SpringBootApplication(
//  scanBasePackages = {"rgc.budgeting.**", "services.**", "configuration.**"},
//  exclude =  { /*DataSourceAutoConfiguration.class, DataSourceTransactionManagerAutoConfiguration.class, HibernateJpaAutoConfiguration.class*/ }
//  scanBasePackages = {"com.leftyab.**"}
)

public class MainApplication {
  public static void main(String[] args) {

//    testPackageScan();
    new SpringApplicationBuilder()
      .bannerMode(Banner.Mode.CONSOLE)
      .sources(MainApplication.class)
      .run(args);
  }

  @PostConstruct
  public void postConstruct() {
//    var handler = ActionsManager.findHandler("testhandlercontainer","updatedocument");
//    var rrrrrrr = handler.getClass();
  }
//  private record Rec(String name, String[] parent) {}
//  private record Rec(String name, String parent) {}
  private static void testPackageScan() {

//    var records = List.of(new Rec("base", new String[]{""}), new Rec("request", new String[]{"base"}), new Rec("order", new String[]{"base"}));
/*
    var records = List.of(new Rec("base", ""), new Rec("request", "base"), new Rec("order", "base"));


    var recordMap = records.stream()
      .collect(Collectors.toMap(x-> x.name(), x-> x.parent() ));

    var recordMapp = records.stream()
      .collect(
        () -> new HashMap<String, HashSet<String>>(),
        (x, y )-> {
          if(x.containsKey(y.name())) {
            x.get(y.name()).add(y.name());
          }
          else {
            x.put(y.name, new HashSet<String>(List.of(y.parent())));
          }
//          return x;
        } , (x, y) -> {return;} );

    List<String> vowels = List.of("a", "e", "i", "o", "u");

// sequential stream - nothing to combine
    StringBuilder result = vowels.stream()
      .collect(StringBuilder::new, (x, y) -> x.append(y), (a, b) -> a.append(",").append(b));
    System.out.println(result.toString());

// parallel stream - combiner is combining partial results
    StringBuilder result1 = vowels.parallelStream().collect(StringBuilder::new, (x, y) -> x.append(y),
      (a, b) -> a.append(",").append(b));
    System.out.println(result1.toString());

*/
    var manager = new ActionsManager(null, new AppActionsProperties(true, new String[]{"com.leftyab.core", "com.leftyab.**"})); //com.leftyab.crm.customers
    manager.configureRepositories();
/*
    var rrr = new ActionHandlerRepositoryFactory(new ActionsProperties(true, new String[]{"com.leftyab.core"}));
      var rrrr = rrr.createRepository("");
*/
  }
}
