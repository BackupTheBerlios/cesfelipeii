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
		ResultSet tablas = dmd.getTables(null,null,null,tipos);

		// Obtenemos todas las tablas del usuario (BD en Oracle)
		// ResultSet tablas = stmt.executeQuery("SELECT TABLE_NAME FROM USER_TABLES ORDER BY TABLE_NAME");

		while (tablas.next())
		{
			out.print("<a href=\"tablas-listado.jsp?TABLA=" + tablas.getString(3) + "\">" + tablas.getString(3) + "</a><br>");
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
</center>
</BODY>

</html>
