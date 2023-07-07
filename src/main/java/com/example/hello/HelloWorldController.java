package com.example.hello;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloWorldController {

	@Autowired
	private HelloWorldConfiguration config;

	@RequestMapping("/")
	public String index() {
		return "Hello " + config.getMessage();
	}

}
