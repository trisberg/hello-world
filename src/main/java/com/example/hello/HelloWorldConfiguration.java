package com.example.hello;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

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
	}
}
