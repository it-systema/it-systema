package com.leftyab.documentflow.mainapp.controllers;

import org.apache.commons.lang3.tuple.Pair;
import org.springframework.http.HttpEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
//@EnableWebSecurity
@RequestMapping("/api/")
public class HomeController {
  public HomeController() {
    super();
  }

  @ResponseBody
  @GetMapping(value = {"/schemaversion"}, produces = "application/json")
  public ResponseEntity<?> documentActionGet(@PathVariable String documentTypeName, @PathVariable String documentAction, @PathVariable(required = false) UUID documentId, HttpEntity<String> httpEntity) {
//    Exception
    return ResponseEntity.ok(new Pair[]{Pair.of("data", "version_value_1"), Pair.of("metadata", "version_value_2")});
//    return  new ResponseEntity<Object[]>(new Pair[]{Pair.of("test1", "value1"), Pair.of("test2", "value2")}, HttpStatus.OK); //, resultStatus

//    return getRequestResult(executeAction(documentTypeName, documentAction, documentId, httpEntity));
  }

/*
  @GetMapping(value = {"/", "/api/"})
//  @RequestMapping(value = "/username", method = RequestMethod.GET)
  public String helloWorld()
  {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    return "Hello "+ auth.getName();
  }

 */

}
