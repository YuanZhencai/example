/** * A1.java 
 * Created on 2014年1月22日 上午11:32:58 
 */

package com.wcs.common.util.vo;

public class A1 extends SubVo {

	private Long Id;
	private String fatherCode;
	private String content;

	public Long getId() {
		return Id;
	}

	public void setId(Long id) {
		Id = id;
	}

	public String getFatherCode() {
		return fatherCode;
	}

	public void setFatherCode(String fatherCode) {
		this.fatherCode = fatherCode;
		setParent(fatherCode);
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}


}
