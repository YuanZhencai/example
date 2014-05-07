package com.wcs.singleton;

import org.junit.Test;

public class SingletonTest {

	@Test
	public void testMode() {
		Singleton.getInstance().mode();
		Singleton1.getInstance().mode();
		Singleton2.getInstance().mode();
		Singleton3.getInstance().mode();
		Singleton4.getInstance().mode();
	}

}
