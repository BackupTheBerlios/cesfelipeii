<%@ page import="java.io.*,java.sql.*,java.util.*" %>
<%@ include file="../WEB-INF/conexion.jsp" %>
<% // El fichero conexion.jsp contiene las variables usuarioBD, claveBD, url y driver con los valores necesarios para conectar a la BD. %>
<HTML>
<HEAD>
<TITLE>Identificaci�n de usuario.</TITLE>
</HEAD>
<BODY>
<%
// Pruebas CVS para chema
try {

   // Tomamos del objeto request el nombre de usuario y la contrase�a
   String login = request.getParameter("usuario");
   String clave = request.getParameter("passwd");

  if (login.equals("") || clave.equals(""))   {
     // Error en la identificaci�n. Nos ahorramos el acceso a la BD
      %>
          <script LANGUAGE="JavaScript">
              <!--
                alert("Error en la identificaci�n");
                window.location = "../default.jsp";
              //-->
	   </script>
      <%
      return;
  }

  // Si no hubo problemas, comprobamos valores
  Connection conn;

  // Variables a almacenar en el objeto session
  int id;					// Identificador de usuario
  String tipoUsuario;				// Tipo de usuario

  try {
     // Cargar el controlador dela BD
     Class.forName(driver);
  } catch (java.lang.ClassNotFoundException e) {
      %>
          <script LANGUAGE="JavaScript">
              <!--
                alert("No se ha podido cargar el Driver de la BD");
                window.location = "../default.jsp";
              //-->
	   </script>
      <%
   }  // Fin de try - catch

  conn = DriverManager.getConnection(url, usuarioBD, claveBD);
  Statement stmt=null;
  stmt = conn.createStatement();

  // Se obtiene el usuario junto a su tipo
  ResultSet rset = stmt.executeQuery("SELECT IDENT,TIPO FROM USUARIOS U1, TIPO_USUARIO U2 WHERE NOMBRE='"+login+"' AND PASSWORD='"+clave+"' AND U1.ID_TIPO_USUARIO = U2.ID_TIPO_USUARIO");

  // Si coincide alguno, habr� un valor en el" resultset"
  if (rset.next())  {
      // Una vez identificado, tomamos sus datos
      id = rset.getInt("IDENT");
      tipoUsuario = rset.getString("TIPO");

       // Y los colocamos en el objeto session para posteriores comprobaciones
      session.putValue("idUsuario",new Integer (id));
      session.putValue("clave",clave);
      session.putValue("tipoUsuario",tipoUsuario);

       /* Ahora, dependiendo del tipo de usuario, se env�a la ejecuci�n a la administraci�n
          sobre todas las tablas o bien al acceso restringido (profe). */
       if (tipoUsuario.equals("ADMIN")) {
          // Usuario administrador
         %>
         <script LANGUAGE="JavaScript">
            // �sta ventana vuelve a default.jsp
            window.location = "../default.jsp";
            // Y se abre una ventana nueva con la parte de administraci�n
            window.open("./acc_admin/");
         </script>
      <%
      } else {
         // Usuario profesor
         %>
         <script LANGUAGE="JavaScript">
            // �sta ventana vuelve a default.jsp
            window.location = "../default.jsp";
            // Y se abre una ventana nueva con la parte de administraci�n
            window.open("./acc_otros/");
         </script>
      <%
      }

   } else { 	// Usuario � clave no v�lidos
          %>
          <script LANGUAGE="JavaScript">
              <!--
                alert("Usuario o contrase�a incorrectos");
                window.location = "../default.jsp";
              //-->
	   </script>
	 <%
      }

} catch (java.lang.NullPointerException e) {
%>
    <script LANGUAGE="JavaScript">
        <!--
          alert("ERROR en la autentificaci�n.");
          window.location = "../default.jsp";
        //-->
   </script>
<%
}
%>
</BODY>
</HTML>
