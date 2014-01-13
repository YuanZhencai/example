package com.wcs.login;

import java.io.IOException;

import javax.faces.FacesException;
import javax.faces.FactoryFinder;
import javax.faces.component.UIViewRoot;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.context.ResponseWriter;
import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;
import javax.faces.render.RenderKit;
import javax.faces.render.RenderKitFactory;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.primefaces.context.RequestContext;

import com.wcs.login.util.FacesUtil;

public class MyJsfAjaxTimeoutPhaseListener implements PhaseListener {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public void afterPhase(PhaseEvent event) {

	}

	public void beforePhase(PhaseEvent event) {
		System.out.println("MyJsfAjaxTimeoutPhaseListener.beforePhase()");
		MyJsfAjaxTimeoutSetting timeoutSetting = (MyJsfAjaxTimeoutSetting) FacesUtil
				.getManagedBean("MyJsfAjaxTimeoutSetting");
		FacesContext fc = FacesContext.getCurrentInstance();
		RequestContext rc = RequestContext.getCurrentInstance();
		ExternalContext ec = fc.getExternalContext();
		HttpServletResponse response = (HttpServletResponse) ec.getResponse();
		HttpServletRequest request = (HttpServletRequest) ec.getRequest();

		HttpSession session = request.getSession(true);
		if (timeoutSetting == null) {
			System.out
					.println("JSF Ajax Timeout Setting is not configured. Do Nothing!");
			return;
		}

		if (session.isNew()) {

			if (ec.isResponseCommitted()) {
				// redirect is not possible
				return;
			}

			try {

				if (((rc != null && RequestContext.getCurrentInstance()
						.isAjaxRequest()) || (fc != null && fc
						.getPartialViewContext().isPartialRequest()))
						&& fc.getResponseWriter() == null
						&& fc.getRenderKit() == null) {

					if (fc.getViewRoot() == null) {
						UIViewRoot view = fc.getApplication().getViewHandler()
								.createView(fc, "");
						fc.setViewRoot(view);
					}
					response.setCharacterEncoding(request
							.getCharacterEncoding());

					RenderKitFactory factory = (RenderKitFactory) FactoryFinder
							.getFactory(FactoryFinder.RENDER_KIT_FACTORY);

					RenderKit renderKit = factory.getRenderKit(fc, fc
							.getApplication().getViewHandler()
							.calculateRenderKitId(fc));

					ResponseWriter responseWriter = renderKit
							.createResponseWriter(response.getWriter(), null,
									request.getCharacterEncoding());
					fc.setResponseWriter(responseWriter);

					ec.redirect(ec.getRequestContextPath()
							+ (timeoutSetting.getTimeoutUrl() != null ? timeoutSetting
									.getTimeoutUrl() : ""));
					System.out.println("[redirect]"
							+ ec.getRequestContextPath()
							+ timeoutSetting.getTimeoutUrl());
				}

			} catch (IOException e) {
				System.out.println("Redirect to the specified page '"
						+ timeoutSetting.getTimeoutUrl() + "' failed");
				throw new FacesException(e);
			}
		} else {
			return; // This is not a timeout case . Do nothing !
		}

	}

	public PhaseId getPhaseId() {
		return PhaseId.RESTORE_VIEW;
	}

}
