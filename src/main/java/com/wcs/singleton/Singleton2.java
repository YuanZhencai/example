package com.wcs.singleton;

public class Singleton2 {

	private static Singleton2 instance = null;
	
	private Singleton2() {
		System.out.println("Singleton2.Singleton2()");
	}
	
	public static synchronized Singleton2 getInstance() {
		if (instance == null) {
			instance = new Singleton2();
		}
		return instance;
	}
	
	public void mode() {
		System.out.println("Singleton2.mode() 饱汉1");
		System.out.println("/* 虽然是安全的 但是效率非常低在一个时候只有一个线程能访问  同时返回一个对象 */");
	}
}
