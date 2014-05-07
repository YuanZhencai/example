package com.wcs.override;

public class Student extends Person {

	@Override
	public void say() {
		System.out.println("Student.say()");
	}

	public String sing(String song) {
		System.out.println("Student.sing() " + song);
		return song;
	}

}
