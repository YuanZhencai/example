package com.wcs.login.util;

import javax.el.ELContext;
import javax.el.ExpressionFactory;
import javax.el.ValueExpression;
import javax.faces.context.FacesContext;

public class FacesUtil {
	private FacesUtil() {
	}

	public static Object getManagedBean(String beanName) {

		FacesContext fc = FacesContext.getCurrentInstance();
		ELContext elc = fc.getELContext();
		ExpressionFactory ef = fc.getApplication().getExpressionFactory();
		ValueExpression ve = ef.createValueExpression(elc, getJsfEl(beanName),
				Object.class);
		return ve.getValue(elc);
	}

	private static String getJsfEl(String value) {
		return "#{" + value + "}";
	}
}
