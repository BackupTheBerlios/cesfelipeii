<%@ page import="java.sql.*" %>
<%@ include file="../../WEB-INF/conexion.jsp" %>
<% // El fichero conexion.jsp contiene las variables usuarioBD, claveBD, url y driver con los valores necesarios para conectar a la BD.%>

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
<title>Edición de tablas</title>
</head>
<body>
<center>
<%
	String p_modo   = request.getParameter("MODO");
	String p_tabla  = request.getParameter("TABLA");
	String p_fila   = request.getParameter("FILA");

	if (p_fila==null) p_fila="0";
	int fila = Integer.parseInt(p_fila);

	try
	{
		if (p_tabla==null || p_modo==null) throw new Exception("Parámetros incorrectos.");
		out.print("<h3>" + p_tabla + "</h3>");
		out.print("[ <a href=\"tablas-listado.jsp?TABLA=" + p_tabla +"\">Volver</a> ]<br><br>");

		Connection canal = null;
		ResultSet registros = null;
		Statement instruccion=null;

		Class.forName(driver);
		canal = DriverManager.getConnection(url,usuarioBD,claveBD);
		instruccion = canal.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,ResultSet.CONCUR_UPDATABLE);
		String sql="select * from " + p_tabla;
		registros = instruccion.executeQuery(sql);
		ResultSetMetaData rsmd = registros.getMetaData();
		int columnas = rsmd.getColumnCount();

		String modo = "";
		if (p_modo.equals("ANADIR"))
		{
			modo="Añadir";
			registros.last();
		}
		else if (p_modo.equals("EDITAR"))
		{
			modo="Actualizar";
			registros.absolute(fila);
		}
		else if (p_modo.equals("BORRAR"))
		{
			modo="Eliminar";
			registros.absolute(fila);
		}
		else throw new Exception("Error en el modo de actualización.");

		out.print("<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"text-align: left; width: 70%;\">");
		out.print("<tbody>");
		out.print("<form id=\"edita\" name=\"form_edita\" method=\"post\" action=\"tablas-listado.jsp?MODO=" + p_modo + "&TABLA=" + p_tabla + "&FILA=" + p_fila + "\">");
		for(int i=1;i<=columnas;i++)
		{
			out.println("<tr>");
			int ancho = rsmd.getColumnDisplaySize(i);
			out.println("<td style=\"vertical-align: top;\">" + rsmd.getColumnName(i) + "</td>");
			out.print("<td style=\"vertical-align: top;\">");
			if (ancho>50) {
				out.print("<textarea name=\"" + rsmd.getColumnName(i) + "\" cols=\"50\" rows=\"" + ancho/50 + "\">" + registros.getString(i) + "</textarea>");
			}
			else
			{
				out.print("<input type=\"text\" name=\"" + rsmd.getColumnName(i) + "\" size=\"" + rsmd.getColumnDisplaySize(i) + "\" value=\"" + registros.getString(i) + "\">");
			}
			out.println("</td>");
			out.println("</tr>");
		}
		out.println("<tr>");
		out.print("<td style=\"vertical-align: top;\">");
		out.print("<br><input type=\"submit\" value=\"" + modo + "\">");
		out.print("<input type=\"reset\" value=\"Restablecer\">");
		out.println("</td>");
		out.println("</tr>");
		out.println("</form>");
		out.println("</tbody>");
		out.println("</table><br><br>");

		registros.close();
		canal.close();
	} // fin try
	catch(Exception e)
	{
		out.print("<h3>Excepción: " + e.getMessage() + "</h3>");
	};
	out.print("[ <a href=\"tablas-listado.jsp?TABLA=" + p_tabla +"\">Volver</a> ]<br><br>");
%>
</center>
</body>
</html>

