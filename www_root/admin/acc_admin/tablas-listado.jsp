<%@ page import="java.sql.*" %>
<%@ include file="../../WEB-INF/conexion.jsp" %>
<% // El fichero conexion.jsp contiene las variables usuarioBD, claveBD, url y driver con los valores necesarios para conectar a la BD.%>

<html>
<head>
<title>Inicio de la administración</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<BODY BGCOLOR="#FFFFFF" BACKGROUND="imagenes/fondo_ces.gif">
<center>
<%
	// Página de vuelta. En la página aparecen dos vínculos [Volver]. En esta cadena se almacena el destino.
	String volver = "default.jsp";

	String p_modo  = request.getParameter("MODO");
	String p_tabla = request.getParameter("TABLA");
	String p_fila  = request.getParameter("FILA");

	if (p_modo==null) p_modo="";
	if (p_fila==null) p_fila="0";
	int fila = Integer.parseInt(p_fila);

	Connection canal = null;
	ResultSet registros = null;
	Statement instruccion=null;
	try {
		// En primer lugar aseguramos que el usuario está identificado:
		Integer idUsuario  = (Integer)session.getAttribute("idUsuario");
		String clave       = (String) session.getAttribute("clave");
		String tipoUsuario = (String) session.getAttribute("tipoUsuario");
		if (idUsuario == null || clave == null || tipoUsuario == null || !tipoUsuario.equals("ADMIN"))
		{
			volver="../index.htm";
			throw new Exception("Zona restringida: debe identificarse.");
		}

		Class.forName(driver);
		canal = DriverManager.getConnection(url,usuarioBD,claveBD);
		instruccion = canal.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,ResultSet.CONCUR_UPDATABLE);

		String sql = null;
		if (sistema.equals("mysql"))
		{
			// ¡MySQL: No funciona como en oracle!
			sql="select * from " + p_tabla;
		}
		else if (sistema.equals("oracle"))
		{
			/* OJO !!!!! Con "select * ..." NO se pueden modificar los resultsets !!!!!!!
			   Hay que cambiar la sentencia con un alias o especificando los campos. */
			// Oracle:
			sql="select t.* from " + p_tabla + " t";
		}
		else // Arquitectura no implementada. Lanzamos excepción:
		{
			volver="../index.htm";
			throw new Exception("Sistema de base de datos " + sistema + " no implementado.");
		}

		registros = instruccion.executeQuery(sql);
		ResultSetMetaData rsmd = registros.getMetaData();
		int columnas = rsmd.getColumnCount();

		try
		{
			if (p_modo.equals("ANADIR"))
			{
				registros.moveToInsertRow();
				for(int i=1;i<=columnas;i++)
					registros.updateObject(i,request.getParameter(rsmd.getColumnName(i)));
				registros.insertRow();
				registros.moveToCurrentRow();

				// Muy lento pero más efectivo, ya que actualiza el formato.
				registros = instruccion.executeQuery(sql);
				//registros.beforeFirst();
			}
			else if (p_modo.equals("EDITAR"))
			{
				if (fila==0) throw new Exception("La fila " + fila + " no existe.");
				registros.absolute(fila);
				for(int i=1;i<=columnas;i++)
					registros.updateObject(i,request.getParameter(rsmd.getColumnName(i)));
				registros.updateRow();
				registros.beforeFirst();
			}
			else if (p_modo.equals("BORRAR"))
			{
				if (fila==0) throw new Exception("La fila " + fila + " no existe.");
				registros.absolute(fila);
				registros.deleteRow();
				registros.beforeFirst();
			}
		}
		catch(Exception e)
		{
			out.print("<h3><font color=\"#FF0000\">Excepción al actualizar la tabla: " + e.getMessage() + "</font></h3><br>");
		};

		int tamano_total = 0;
		out.println("<h3>" + p_tabla + "</h3>");
		out.println("[ <a href=\"" + volver + "\">Volver</a> ]<br><br>");
		out.println("<table cellpadding=\"0\" cellspacing=\"0\" border=\"1\" style=\"width: 100%; text-align: left;\">");
		for (int i=1; i<=columnas; i++)
		{
			tamano_total += rsmd.getColumnDisplaySize(i);
		}
		out.print("<tbody>");
		out.print("<tr>");
		for (int i=1; i<=columnas; i++)
		{
			// Se calcula el ancho de cada columna en base al 90%, 10% para enlaces de edición
			int ancho = (rsmd.getColumnDisplaySize(i)*90)/tamano_total;
			//out.print("<td style=\"vertical-align: top; text-align: center;\" width=\"" + ancho + "%\">" + rsmd.getColumnName(i) + "</td>");
			out.print("<td style=\"vertical-align: top; text-align: center;\">" + rsmd.getColumnName(i) + "</td>");
		}
		//out.print("<td style=\"vertical-align: top;\" width=\"10%\"></td>");
		out.print("<td style=\"vertical-align: top;\"></td>");
    	out.print("</tr>");
		while(registros.next())
		{
			out.print("<TR>");
			for (int i=1; i<=columnas; i++)
			{
				// Se calcula el ancho de cada columna en base al 90%, 10% para enlaces de edición
				// int ancho = (rsmd.getColumnDisplaySize(i)*90)/tamano_total;
				out.print("<td style=\"vertical-align: top; text-align: center;\"><font size=\"-1\">" + registros.getString(i) + "</font></td>");
			}
			//out.print("<td style=\"vertical-align: top;\" width=\"10%\"><font size=\"-1\"><a href=\"noticias-form.jsp?MODO=EDITAR&CLAVE=" + p_tabla + "\">Editar</a> <a href=\"noticias-form.jsp?MODO=BORRAR&CLAVE=" + p_tabla + "\">Borrar</a></font></td>");
			out.print("<td style=\"vertical-align: top;\"><font size=\"-1\"><a href=\"tablas-form.jsp?MODO=EDITAR&TABLA=" + p_tabla + "&FILA=" + Integer.toString(registros.getRow()) + "\">Editar</a> <a href=\"tablas-form.jsp?MODO=BORRAR&TABLA=" + p_tabla + "&FILA=" + Integer.toString(registros.getRow()) + "\">Borrar</a></font></td>");
			out.print("</TR>");
		}; // fin while
		out.print("<tr>");
		out.print("<td style=\"vertical-align: top;\"><font size=\"-1\"><a href=\"tablas-form.jsp?MODO=ANADIR&TABLA=" + p_tabla + "\">Añadir</a></font></td>");
	    out.print("</tr>");
		out.print("</tbody>");
		out.print("</table>");
		out.print("<br>");

		registros.close();
		canal.close();
	} // fin try
	catch(Exception e)
	{
		out.print("<h3><font color=\"#FF0000\">Excepción: " + e.getMessage() + "</font></h3>");
		// Creo que la siguiente línea no es necesaria.
		//out.print("[ <a href=\"" + volver + "\">Volver</a> ]<br><br>");
	};

	out.println("[ <a href=\"" + volver + "\">Volver</a> ]<br><br>");
%>
</center>
</BODY>
</html>
