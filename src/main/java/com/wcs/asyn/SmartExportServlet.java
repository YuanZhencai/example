package com.wcs.asyn;

import java.io.IOException;
import java.util.concurrent.Future;

import javax.ejb.EJB;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class SmartExportServlet
 */
@WebServlet("/SmartExportServlet")
public class SmartExportServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@EJB
	private AsyncInterface messageService;

	private Future<String> future;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public SmartExportServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/xml; charset=UTF-8");
		response.setHeader("Cache-Control", "no-cache");
		int complete = -1;
		try {
			if (future != null && future.isDone()) {
				complete = 1;
				future = null;
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		System.out.println("[complete]" + complete);
		response.getWriter().print(complete);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("SmartExportServlet.doPost()");
		if (future == null || (future != null && future.isDone())) {
			future = messageService.sendMessages("hello world");
		}
		System.out.println(" end SmartExportServlet.doPost()");
	}

}
