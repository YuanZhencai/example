package com.wcs.singleton;

public class Singleton4 {

	
	private Singleton4() {
		System.out.println("Singleton4.Singleton4()");
	}
	
	private  static class SingletonFactory {
		private static Singleton4 instance = new Singleton4();
	}
	
	public static Singleton4 getInstance() {
		return SingletonFactory.instance;
	}
	
	public void mode() {
		System.out.println("Singleton4.mode() 内部类单例");
		System.out.println("/* 线程安全  并且效率高  能有多个线程访问 */");
	}
}
