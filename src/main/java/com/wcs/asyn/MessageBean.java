/** * MessageBean.java 
 * Created on 2014年1月10日 下午2:16:35 
 */

package com.wcs.asyn;

import java.io.Serializable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

import javax.ejb.EJB;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;

import org.primefaces.context.RequestContext;

@ManagedBean(name = "messageBean")
@ViewScoped
public class MessageBean implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@EJB
	private AsyncInterface messageService;

	private Future<String> future;

	private String status;
	private boolean exportButtonRender = true;

	public void sendMany() {
		System.out.println("[msg1]" + messageService.sendMessages("Hello World"));
		System.out.println("[msg2]" + messageService.sendMessages("Hello World"));
		System.out.println("[msg3]" + messageService.sendMessages("Hello World"));
		System.out.println("[msg4]" + messageService.sendMessages("Hello World"));
	}

	public void sendMessages() {
		System.out.println("MessageBean.sendMessages()");
//		exportButtonRender = false;
		FacesMessage msg = new FacesMessage(FacesMessage.SEVERITY_INFO, "bean:", "complete");
		FacesContext.getCurrentInstance().addMessage(null, msg);

	}

	public void cancel() {
		System.out.println("MessageBean.cancel()");
		System.out.println("[cancel]" + future.cancel(true));
	}

	public void export() {
		if (future == null || (future != null && future.isDone())) {
			future = messageService.sendMessages("Export Smart Zip");
			FacesMessage msg = new FacesMessage(FacesMessage.SEVERITY_INFO, "开始打包：", "请耐心等待");
			FacesContext.getCurrentInstance().addMessage(null, msg);
			exportButtonRender = false;
		}
	}

	public void complete() {
		System.out.println("MessageBean.complete()");
//		exportButtonRender = true;
		FacesMessage msg = new FacesMessage(FacesMessage.SEVERITY_INFO, "打包成功：", "请到下载页面下载");
		FacesContext.getCurrentInstance().addMessage(null, msg);
	}

	public Future<String> getFuture() {
		if (future.isDone()) {
			try {
				System.out.println("return back status is " + future.get());
			} catch (InterruptedException e) {
				e.printStackTrace();
			} catch (ExecutionException e) {
				e.printStackTrace();
			}
		}
		return future;
	}

	public void setFuture(Future<String> future) {
		this.future = future;
	}

	public String getStatus() {
		if (future != null && future.isDone()) {
			try {
				System.out.println("return back status is " + future.get());
				status = future.get();
			} catch (InterruptedException e) {
				e.printStackTrace();
			} catch (ExecutionException e) {
				e.printStackTrace();
			}
		}
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public boolean isExportButtonRender() {
		return exportButtonRender;
	}

	public void setExportButtonRender(boolean exportButtonRender) {
		this.exportButtonRender = exportButtonRender;
	}

}
