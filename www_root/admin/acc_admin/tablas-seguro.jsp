<%@ include file="../../WEB-INF/conexion.jsp" %>
<% // El fichero conexion.jsp contiene las variables usuarioBD, claveBD, url y driver con los valores necesarios para conectar a la BD.%>
<%@ include file="lib-inc.jsp"%>
<% // Librería de obtención de definición y contenido da tablas, así como algunas funciones útiles.%>
<%
	// Salto de linea:
	String salto = "\n";

	response.setHeader("Content-disposition","filename=backup.sql");
    response.setHeader("Content-type","application/octetstream");
    response.setHeader("Pragma","no-cache");
    response.setHeader("Expires","0");
    String client = request.getHeader("USER-AGENT");
    if (client.indexOf("(")>0 && client.indexOf(")")>0) {
        client = client.substring(client.indexOf("(")+1, client.indexOf(")"));
        client=client.toLowerCase();
        if (client.indexOf("win")>-1) {
           salto="\r\n";
        }
    }

	try {
		// En primer lugar aseguramos que el usuario está identificado:
		Integer idUsuario  = (Integer)session.getAttribute("idUsuario");
		String clave       = (String) session.getAttribute("clave");
		String tipoUsuario = (String) session.getAttribute("tipoUsuario");
		if (idUsuario == null || clave == null || tipoUsuario == null || !tipoUsuario.equals("ADMIN"))
		{
			throw new Exception("Zona restringida: debe identificarse.");
		}

		Class.forName(driver);
		Connection canal = null;
		canal = DriverManager.getConnection(url,usuarioBD,claveBD);
		// Cogemos la lista de tablas:
		DatabaseMetaData dmd = canal.getMetaData();
		String[] tipos = {"TABLE"};
		ResultSet tablas = null;

		// De momento solo implementado para mysql
		if (sistema.equals("mysql"))
			tablas = dmd.getTables(null,null,null,tipos);
		else // Lanzamos excepción. La arquitectura no está implementada:
		{
			throw new Exception("La arquitectura de base de datos " + sistema + " no está implementada.");
		}

		while (tablas.next())
		{
			String bdtabla = tablas.getString(3);
			out.print(salto);
			out.print("# --------------------------------------------------------"+salto);
			out.print("#"+salto);
			out.print("# Estructura de la tabla '"+ bdtabla + "'" + salto);
			out.print("#" + salto);
			out.print(salto);

			// Calculamos la definición de la tabla:
			out.print(dame_def_tabla(canal,bdtabla,salto)+";"+salto+salto);
			String[] sql_inserts = dame_ins_tabla(canal,bdtabla);
			for (int i=0;i<sql_inserts.length ;i++ ) out.print(sql_inserts[i] + salto);
		}
		tablas.close();
		canal.close();
	} // fin try
	catch(Exception e)
	{
		out.println(salto + e.getMessage() + salto);
	};
%>
