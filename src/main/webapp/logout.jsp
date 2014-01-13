
<%
	session.invalidate();
	response.sendRedirect(request.getContextPath()+"/faces/index.xhtml");
%>