package com.example.hello;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloWorldController {

	private static Logger logger = LoggerFactory.getLogger(HelloWorldController.class);

	@Autowired
	private HelloWorldConfiguration config;

	@RequestMapping("/")
	public String index() {
		logger.info("Received request for /");
		logger.info("app.message: " + config.getMessage());
		logger.info("CRAC_FILES_DIR: " + System.getenv("CRAC_FILES_DIR"));
		return "Hello " + config.getMessage();
	}

}
