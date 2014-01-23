/** * SmartService.java 
 * Created on 2014年1月17日 下午2:58:27 
 */

package com.wcs.asyn;

import java.util.concurrent.Future;

import javax.ejb.AsyncResult;
import javax.ejb.Asynchronous;
import javax.ejb.Stateless;


/** 
* <p>Project: example</p> 
* <p>Title: SmartService.java</p> 
* <p>Description: </p> 
* <p>Copyright (c) 2014 Wilmar Consultancy Services</p>
* <p>All Rights Reserved.</p>
* @author <a href="mailto:yuanzhencai@wcs-global.com">Yuan</a> 
*/
@Stateless
public class SmartService {

	@Asynchronous
	public Future<String> export() {
		System.out.println("begin SmartService.export()");
		try {
			Thread.sleep(1000 * 15);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("end SmartService.export()");
		return new AsyncResult<String>("1");
	}
}
