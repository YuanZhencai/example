package com.wcs.singleton;

public class Singleton1 {

	private static Singleton1 instance = null;
	
	private Singleton1() {
		System.out.println("Singleton1.Singleton1()");
	}
	
	public static Singleton1 getInstance() {
		if (instance == null) {
			instance = new Singleton1();
		}
		return instance;
	}
	
	public void mode() {
		System.out.println("Singleton1.mode() 饱汉");
		System.out.println("/* 饱汉方式的单例模式 但是有多个线程访问时就不是安全的 返回的不是同一个对象 */");
	}
}
