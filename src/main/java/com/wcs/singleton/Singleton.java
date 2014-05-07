package com.wcs.singleton;

public class Singleton {

	private static Singleton instance = new Singleton();
	
	private Singleton() {
		System.out.println("Singleton.Singleton()");
	}
	
	public static Singleton getInstance() {
		return instance;
	}
	
	public void mode() {
		System.out.println("Singleton.mode() 饿汉");
		System.out.println("/* 线程安全 但效率比较低  一开始就要加载类new一个 对象 这是饿汉方式的单例模式*/");
	}
}
