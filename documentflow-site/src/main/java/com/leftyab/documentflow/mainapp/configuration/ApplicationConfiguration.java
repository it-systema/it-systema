package com.leftyab.documentflow.mainapp.configuration;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.leftyab.core.actions.services.ActionRepository;
import com.leftyab.crm.customers.CustomerActionHandlerRepository;
import com.leftyab.documentflow.datamodel.entity.SysClass;
import com.leftyab.documentflow.datamodel.entity.references.RefCounterparty;
import com.leftyab.documentflow.services.actions.ObjectActionHandlerRepository;
import jakarta.persistence.EntityManagerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ApplicationConfiguration  {
  @Bean("customer")
  public ActionRepository customerActionHandlerRepository(EntityManagerFactory entityManagerFactory, ObjectMapper objectMapper) {
//    return new TestHandlerContainerBase("basecontainerhandlers");
    return new CustomerActionHandlerRepository("customer", RefCounterparty.class, entityManagerFactory, objectMapper);
  }

  /*
    @Bean
    @Scope("request")
  //  @RequestScope()
    public EntityManager entityManager(EntityManagerFactory entityManagerFactory){
      return entityManagerFactory.createEntityManager();
    }
    @Bean
    @ActionHandlerRepository(name = "testhandlercontainer", parent = "basecontainerhandlers")
    public TestHandlerService getTestHandlerService() {
      return new TestHandlerService();
    }
  */
//  @Bean(name = "tcApplication")
/*
  public IDocumentTypeService<TcApplication> getTcApplication(EntityManagerFactory entityManagerFactory, ObjectMapper objectMapper){
    return new DocumentTypeService<TcApplication>("tcApplication", TcApplication.class);
//    return null;
  }

 */
}
/*
@Configuration
public class ApplicationConfiguration extends DefaultConfiguration {
	@Value("${rgc.budgeting.rootFilePath}")
	private String rootFilePath;
	@Value("${rgc.budgeting.fileHashAlgorithm}")
	private String fileHashAlgorithm;

	public ApplicationConfiguration(ApplicationContext applicationContext)
	{
		super(applicationContext.getEnvironment());
	}



	String hazelcastConfigFile;
	@Value("${rgc.budgeting.hazelcast.instanceName}")
	private String hazelcastInstanceName;
	@Bean(name = "hazelcastConfig")
	public Config hazelcastConfig() throws FileNotFoundException {
		Config config;
		if(hazelcastConfigFile == null || hazelcastConfigFile.isBlank()) {
			config = new Config();
			config.setInstanceName(hazelcastInstanceName);
		}
		else {
			config = new XmlConfigBuilder(hazelcastConfigFile).build();
		}
		return config;
	}
//----------------------------------------------------------------------------------------------------------------------
//document services
//----------------------------------------------------------------------------------------------------------------------

	@Bean
//	@DependsOn({"entityManagerFactory"})
	public BudgetProjectTypeService budgetProjectTypeService(EntityManagerFactory entityManagerFactory){
		var budgetProjectTypeBuilder = new BudgetProjectTypeService.BudgetProjectTypeServiceBuilder(entityManagerFactory);

		return (BudgetProjectTypeService)budgetProjectTypeBuilder
			.setDocumentTypeName("project")
			.build();
	}
	@Bean
	@DependsOn({"budgetProjectTypeService"})
	public BudgetProjectCommandManager budgetProjectCommandManager(BudgetProjectTypeService budgetProjectTypeService, ILockManagerFactory lockManagerFactory){
		return new BudgetProjectCommandManager(budgetProjectTypeService, lockManagerFactory);
	}

	@Bean
	public RequestTypeService requestTypeService(EntityManagerFactory entityManagerFactory){
		var requestTypeBuilder = new RequestTypeService.RequestTypeServiceBuilder(entityManagerFactory);
		return (RequestTypeService)requestTypeBuilder
			.setDocumentTypeName("request")
//			.setTypeClass(Request.class)
//			.setClassName("request")
			.build();
//		return new RequestTypeService(entityManagerFactory);
	}
	@Bean
	@DependsOn({"requestTypeService"})
	public RequestCommandManager requestCommandManager(RequestTypeService requestTypeService, ILockManagerFactory lockManagerFactory) {
		return new RequestCommandManager(requestTypeService, lockManagerFactory);
	}

}
*/
