package com.wcs.override;

import static org.junit.Assert.*;

import org.junit.Test;

public class OverrideTest {
	
	private Person p = new Person();
	
	private Student s = new Student();

	@Test
	public void testSay() {
		p.say();
		s.say();
	}

	@Test
	public void testSing() {
		p.sing();
		s.sing();
		assertEquals("I Love Youe", s.sing("I Love Youe"));
	}

}
