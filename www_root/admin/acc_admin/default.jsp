<%@ page import="java.sql.*" %>
<%@ include file="../../WEB-INF/conexion.jsp" %>
<% // El fichero conexion.jsp contiene las variables usuarioBD, claveBD, url y driver con los valores necesarios para conectar a la BD.

	// Primero hay que comprobar que no se haya "colado" el usuario utilizando los atributos de sesión
	Integer idUsu  = (Integer)session.getAttribute("idUsuario");
	String clave = (String)session.getAttribute("clave");
	String tipoUsu = (String)session.getAttribute("tipoUsuario");

	if (idUsu == null || clave == null || tipoUsu == null || !tipoUsu.equals("ADMIN")) {
	// Si alguno de los parámetros está vacío, se pide una nueva identificación.
          %>
          <script LANGUAGE="JavaScript">
              <!--
                alert("Zona restringida: debe identificarse.");
                window.location = "../";
              //-->
	   </script>
	 <%
	} else {

	   Connection canal = null;
	   Statement stmt = null;

	   try {
		Class.forName(driver);
		canal = DriverManager.getConnection(url, usuarioBD, claveBD);

		stmt = canal.createStatement();

         %>
<html>
<head>
<title>Administraci&oacute;n de BD C.E.S.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<BODY BGCOLOR="#FFFFFF" BACKGROUND="imagenes/fondo_ces.gif">
<center>

<h3>Tablas:</h3>
[ <a href="../">Volver</a> ]<br><br>

	   <%

		// Muestra la lista de tablas
		DatabaseMetaData dmd = canal.getMetaData();
		String[] tipos = {"TABLE"};
		ResultSet tablas = null;

		// Columna correspondiente al nombre de la tabla.
		// Si al final la implementación entre una base de datos u otra cambia, la columna cambiará.
		int columna = 0;

		if (sistema.equals("mysql"))
		{
			tablas = dmd.getTables(null,null,null,tipos);
			columna = 3;
		}
		else if (sistema.equals("oracle"))
		{
			// Prueba para ver si funciona con Oracle.
			tablas = dmd.getTables(null,null,null,tipos);
			columna = 3;
			// Obtenemos todas las tablas del usuario (BD en Oracle)
			// tablas = stmt.executeQuery("SELECT TABLE_NAME FROM USER_TABLES ORDER BY TABLE_NAME");
		}
		else // Lanzamos excepción. La arquitectura no está implementada:
		{
			throw new Exception("La arquitectura de base de datos " + sistema + " no está implementada.");
		}

		while (tablas.next())
		{
			out.print("<a href=\"tablas-listado.jsp?TABLA=" + tablas.getString(columna) + "\">" + tablas.getString(columna) + "</a><br>");
		}
		tablas.close();
		canal.close();
	   }
	   catch(Exception e)
	   {
		out.print("<h3>Excepción: " + e.getMessage() + "</h3>");
	   };

	} // Fin del "else" para comprobaciónde parámetros vacíos.

%>
<br><br>[ <a href="../">Volver</a> ]
<br><br>[ <a href="tablas-seguro.jsp">Copia de Seguridad</a> ]
</center>
</BODY>

</html>
