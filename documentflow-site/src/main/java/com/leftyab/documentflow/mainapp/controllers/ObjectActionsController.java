package com.leftyab.documentflow.mainapp.controllers;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.leftyab.core.actions.defaults.ActionResult;
import com.leftyab.core.actions.interfaces.IActionHandlerProvider;
import com.leftyab.documentflow.spring.services.ObjectWebService;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;

import java.util.UUID;


@RestController
@RequestMapping("/api/document")
public class ObjectActionsController extends ObjectWebService {
  public ObjectActionsController(IActionHandlerProvider actionHandlerProvider, ObjectMapper objectMapper) {
    super(actionHandlerProvider, objectMapper);
  }

  /*
    //  @Autowired
    private final ApplicationContext applicationContext;
    private final ObjectMapper objectMapper;

    public DocumentController(ApplicationContext applicationContext, ObjectMapper objectMapper)
    {
      this.applicationContext = applicationContext;
      this.objectMapper = objectMapper;
    }
  */
/*
  @ResponseBody
  @GetMapping(value = {"/{objectName}/list",}, produces = "application/json")
  public ResponseEntity<?> objectActionGetList(@PathVariable String objectName, @RequestParam(name = "searchParam") SearchParameters searchParam, HttpServletRequest request) throws JsonProcessingException {
    try {
      return getRequestResult(executeAction(objectName, "list", UUID.randomUUID(), request));
    }
    catch(Exception ex) {
      return getRequestResult(ActionResult.createErrorResult(ex.getMessage()));
    }
  }

 */
  @ResponseBody
  @GetMapping(value = {"/{objectName}/{actionName}", "/{objectName}/{actionName}/{id}"}, produces = "application/json")
  public ResponseEntity<?> objectActionGet(@PathVariable String objectName, @PathVariable String actionName, @PathVariable(required = false) UUID id, HttpServletRequest request) throws JsonProcessingException {
    try {
      return getRequestResult(executeAction(objectName, actionName, id, request));
    }
    catch(Exception ex) {
      return getRequestResult(ActionResult.createErrorResult(ex.getMessage()));
    }
  }

  @ResponseBody
  @PostMapping(value = {"/{objectName}/{actionName}", "/{objectName}/{actionName}/{id}"}, produces = "application/json", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
  public ResponseEntity<?> objectActionPostForm(@PathVariable String objectName, @PathVariable String actionName, @PathVariable(required = false) UUID id, HttpServletRequest request) {
    try {
      return getRequestResult(executeAction(objectName, actionName, id, request));
    }
    catch(Exception ex) {
      return getRequestResult(ActionResult.createErrorResult(ex.getMessage()));
    }
  }

  @ResponseBody
  @PostMapping(value = {"/{objectName}/{actionName}", "/{objectName}/{actionName}/{id}"}, produces = "application/json", consumes = "application/json")
  public ResponseEntity<?> objectActionPostJson(@PathVariable String objectName, @PathVariable String actionName, @PathVariable(required = false) UUID id, HttpEntity<String> httpEntity) {
    try {
      return getRequestResult(executeAction(objectName, actionName, id, httpEntity));
    }
    catch(Exception ex) {
      return getRequestResult(ActionResult.createErrorResult(ex.getMessage()));
    }
  }
/*

  private static ResponseEntity<?> createRequestResult(IActionResult actionResult) {
    if(actionResult != null) {
      if(actionResult.getResultData() instanceof FileData fileData) {
        return createFileResult(fileData);
      }
      var resultStatus = actionResult.isSuccess() ? HttpStatus.OK : HttpStatus.PRECONDITION_FAILED;
      return new ResponseEntity<>(commandResult, resultStatus);
    }
    return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
  }
  private static ResponseEntity createFileResult(FileData fileData)
  {
    HttpHeaders headers = new HttpHeaders();
    headers.add(HttpHeaders.CONTENT_DISPOSITION, String.format("attachment; filename=%s", fileData.getFileName()));

    return ResponseEntity.ok()
      .headers(headers)
      .contentLength(fileData.getFileSize())
      .contentType(MediaType.valueOf( fileData.getContentType()))
      .body(fileData.getFileBody());
  }
  private ICommandResult executeCommand(String documentTypeName, String documentCommand, UUID documentId, HttpServletRequest request) throws JsonProcessingException{
    MultipartHttpServletRequest multipartRequest = (MultipartHttpServletRequest)request;
    var formData = multipartRequest.getParameterMap();

    Map<String, String> newMerged = new HashMap<>();

    formData.forEach((key, value) -> newMerged.put(key, Arrays.stream(value).findFirst().get()));

    String jsonString = objectMapper.writeValueAsString(newMerged);

    HttpEntity<String> httpEntity = new HttpEntity<>(jsonString);

    var fileData = multipartRequest.getFileMap();

    return executeCommand(documentTypeName, documentCommand, documentId, httpEntity, fileData);
  }
  private ICommandResult executeCommand(String documentTypeName, String documentCommand, UUID documentId, HttpEntity<String> httpEntity) {
    return executeCommand(documentTypeName,documentCommand,documentId, httpEntity, null);
  }

  private ICommandResult executeCommand(String documentTypeName, String documentCommand, UUID documentId, HttpEntity<String> httpEntity, Map<String, MultipartFile> files){

    var typeServiceClass = DocumentCommandManagerService.getCommandsManagerClass(documentTypeName);
    if(typeServiceClass == null) {
      return CommandResult.createErrorResult(String.format("Тип документа \"%s\" не не поддерживается или не зарегистрирован.", documentTypeName) );
    }
    var commandHandlersClass = DocumentCommandManagerService.getCommandsManagerClass(documentTypeName);
    if(commandHandlersClass == null) {
      return CommandResult.createErrorResult("Тип документа '%s' не поддерживаеться", documentTypeName);
    }
    IDocumentCommandManager commandHandlers = (IDocumentCommandManager)this.applicationContext.getBean(commandHandlersClass);

    try {
      var jsonString = httpEntity.hasBody() ? httpEntity.getBody() : "{}";
      var jsonParams = objectMapper.readTree(jsonString);

      var user = (RgcUserDetails)UserDetailsServiceImpl.getPrincipal();//this.getCurrentUser();

      return commandHandlers.executeCommand(documentCommand, user, new HashMap<String, Object>() {{ put("documentId", documentId); put("request", jsonParams); put("files", files);}});
    }
    catch(Exception e) {
      return CommandResult.createErrorResult(e.getMessage());
    }
  }
*/
/*
  private IUser getCurrentUser() throws AccessException{
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    var principal = (RgcUserDetails)auth.getPrincipal();
    var user = (IUser)principal;//.getUser();
    return user;
  }

 */
}
