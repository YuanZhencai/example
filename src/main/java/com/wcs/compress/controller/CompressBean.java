package com.wcs.compress.controller;

import java.io.InputStream;
import java.util.Date;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.servlet.ServletContext;

import org.primefaces.model.DefaultStreamedContent;
import org.primefaces.model.StreamedContent;

import com.wcs.compress.util.CompressUtil;

@ManagedBean(name = "compressBean")
@ViewScoped
public class CompressBean {
	public CompressBean() {
	}

	public StreamedContent compress() {
		System.out.println("CompressBean.compress()");
		String needtozipfilepath = "C:\\Users\\Yuan\\Desktop\\test\\";
		ServletContext context = (ServletContext) FacesContext.getCurrentInstance().getExternalContext().getContext();
		String zipfilepath = new Date().getTime() + ".zip";
		CompressUtil.zip(needtozipfilepath, context.getRealPath("/") + zipfilepath);
		System.out.println("[zipfilepath]" + zipfilepath);
		InputStream stream = context.getResourceAsStream("/"+zipfilepath);
		return new DefaultStreamedContent(stream, "application/zip", zipfilepath);
	}

}
