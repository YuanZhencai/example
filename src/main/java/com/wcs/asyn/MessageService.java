/** * MessageService.java 
 * Created on 2014年1月10日 下午2:10:01 
 */

package com.wcs.asyn;

import java.util.Date;
import java.util.concurrent.Future;

import javax.annotation.Resource;
import javax.ejb.AsyncResult;
import javax.ejb.Asynchronous;
import javax.ejb.Remote;
import javax.ejb.SessionContext;
import javax.ejb.Stateless;

@Stateless
@Remote(AsyncInterface.class)
public class MessageService {
	@Resource
	private SessionContext ctx;

	@Asynchronous
	public Future<String> sendMessages(String message) {

		Date date = new Date();
		System.out.println(" begin MessageService.sendMessages()" + date);
		try {
			Thread.sleep(1000 * 15);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println(" end MessageService.sendMessages() complete" + new Date());
		return new AsyncResult<String>("1");
	}
}
