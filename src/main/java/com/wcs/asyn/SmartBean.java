/** * SmartBean.java 
 * Created on 2014年1月17日 下午3:00:45 
 */

package com.wcs.asyn;

import java.util.concurrent.Future;

import javax.annotation.PostConstruct;
import javax.ejb.EJB;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;

import org.primefaces.context.RequestContext;

@ManagedBean
@SessionScoped
public class SmartBean {
	@EJB
	private SmartService smartService;
	private Future<String> future;

	public SmartBean() {
		System.out.println("SmartBean.SmartBean()");
	}

	@PostConstruct
	public void init() {
		System.out.println("SmartBean.init()");
	}

	public void showMessage() {
		FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, "成功：", "成功"));
	}
	public void expport() {
		System.out.println("SmartBean.expport()");
		future = smartService.export();
		FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, "开始导出：", "请耐心导出"));
	}

	public void getExportStatus() {
		String status = "";
		if (future != null && future.isDone()) {
			FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, "精灵导出：", "成功"));
			status = "1";
			future = null;
		}
		System.out.println("[status]" + status);
		RequestContext.getCurrentInstance().addCallbackParam("status", status);
		status = "";
	}

}
