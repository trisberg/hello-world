package com.springdeveloper.hello;

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
		String ts = java.time.Clock.systemUTC().instant().toString();
		String pod = System.getenv("HOSTNAME");
		if (pod == null) {
			pod = "local";
		}
		String message = config.getMessage() + " from " + pod + " at " + ts;
		logger.info("Message: " + message);
		return "Hello " + message;
	}

}
