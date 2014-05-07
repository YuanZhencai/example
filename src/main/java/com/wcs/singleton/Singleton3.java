package com.wcs.singleton;

public class Singleton3 {

	private static Singleton3 instance = null;
	
	private Singleton3() {
		System.out.println("Singleton3.Singleton3()");
	}
	
	public static Singleton3 getInstance() {
		if (instance == null) {
			synchronized (Singleton3.class) {
				if (instance == null) {
					instance = new Singleton3();
				}
			}
		}
		return instance;
	}
	
	public void mode() {
		System.out.println("Singleton3.mode() 饱汉2");
		System.out.println("/* 线程安全  并且效率高  能有多个线程访问 */");
	}
}
