package com.springdeveloper.hello;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.EventListener;

import jakarta.annotation.PostConstruct;

@Configuration
@ConfigurationProperties(prefix = "app")
public class HelloWorldConfiguration {

	private static Logger logger = LoggerFactory.getLogger(HelloWorldConfiguration.class);
	
	private String message;

	public String getMessage() {
		return this.message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	@PostConstruct
	public void postConstruct () {
		logger.info("app.message: " + message);
		logger.info("CRAC_FILES_DIR: " + System.getenv("CRAC_FILES_DIR"));
	}

	@EventListener
	public void handleContextCloseEvent(ContextClosedEvent ctxCloseEvt) {
 		logger.info("Context Close Event received.");
	}

}
