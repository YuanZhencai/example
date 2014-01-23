package com.wcs.login;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ManagedBean(name = "loginBean")
@ViewScoped
public class LoginBean {
	private String user = null;

	public LoginBean() {
		System.out.println("LoginBean.LoginBean()");
	}

	@PostConstruct
	public void init() {
		System.out.println("LoginBean.init()");
	}

	public void logout() {
		System.out.println("LoginBean.logout()");
		System.out.println("[user]" + user);
	}

	public String getUser() {
		return user;
	}

	public void setUser(String user) {
		this.user = user;
	}

}
