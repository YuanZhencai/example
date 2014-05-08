package com.wcs.login;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.commons.beanutils.BeanUtils;

import com.wcs.common.util.vo.SubVo;

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

	public static void main(String[] args) {
		// List<String> ss = new ArrayList<String>();
		// for (int i = 0; i < 10; i++) {
		// ss.add(i+"");
		// }
		// String string = ss.toString();
		// System.out.println(string);
		SubVo cv = new SubVo();
		cv.setParent("dadsad");
		SubVo cv1 = new SubVo();
		System.out.println("[cv1]" + cv1.getParent());
		try {
			BeanUtils.copyProperties(cv1, cv);
			System.out.println("[cv1]" + cv1.getParent());
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
