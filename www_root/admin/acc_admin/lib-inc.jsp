<%@ page language="java" import="java.io.*,java.sql.*,java.util.*" %>
<%!
// Calcula el número de filas de un conjunto de registros
public int mysql_num_rows(ResultSet rset) throws SQLException {
        int current = 0;
        try {
        if (!rset.isBeforeFirst()) {
            current = rset.getRow();
            rset.beforeFirst();
        }
        }
        catch (Exception e) {
                return -1;
        }
        int number_of_rows=0;
        while (rset.next()) {
                number_of_rows++;
        }
        if (current!=0) {
            rset.absolute(current);
        }
        else {
            rset.beforeFirst();
        }
        return number_of_rows;
}

// Función que añade caracteres especiales para la correcta impresión de source.
public String addSlashes(String source) {
        if (source == null)
        {
            return "";
        }
        StringBuffer dest= new StringBuffer(source.length());
        for (int i=0;i<source.length() ;i++ ) {
            char c;
            c=source.charAt(i);
     	if (c=='"') {
	    dest.append("\\\"");
        }
        else if (c=='\'') {
            dest.append("\\\'");
        }
        else if (c=='\\') {
            dest.append("\\\\");
        }
        else if ((c=='N') && ((i+2)<source.length()) && (source.charAt(i+1) == 'U') && (source.charAt(i+2) == 'L')) {
            dest.append("\\N");
        }
        else {
             dest.append(c);
        }
 }
  return dest.toString();
}//Fin de public String addSlashes(String source)

// Inversa de la anterior
public String stripSlashes(String source) {
        if (source == null)
        {
            return "";
        }
        StringBuffer dest= new StringBuffer(source.length());
        for (int i=0;i<source.length() ;i++ ) {
            char c;
            c=source.charAt(i);
     	if ( (c=='\\') && (i+1<source.length()) && ( source.charAt(i+1)=='\'') ) {
            dest.append("\'");
            i++;
        }
        else if ( (c=='\\') && (i+1<source.length()) && ( source.charAt(i+1)=='\"') ) {
            dest.append("\"");
            i++;
        }
        else if ( (c=='\\') && ((i+3)<source.length()) && (source.charAt(i+1) == 'N') && (source.charAt(i+2) == 'U') && (source.charAt(i+3) == 'L')  ) {
            dest.append("N");
            i++;
        }
        else if ( (c=='\\') && (i+1<source.length()) && ( source.charAt(i+1)=='\\') ) {
            dest.append("\\");
            i++;
        }
        else {
             dest.append(c);
        }
 }
  return dest.toString();
}//Fin de public String nl2Br(String source)

// Reemplaza la última aparición de un elemento por otra cosa.
public String replaceLast(String source, String occurence, String replacement)
{
	if (source.lastIndexOf(occurence)==source.length()-occurence.length())
		return source.substring(0,source.lastIndexOf(occurence)) + replacement;
	else
		return source;
}

public Hashtable mysql_fetch_hashtable(ResultSet rset) throws SQLException
{
	if (rset.next() ) {
		ResultSetMetaData rsdt = rset.getMetaData();
		Hashtable fetch = new Hashtable();
		for (int i=1; i<=rsdt.getColumnCount(); i++ ) {
			String content = rset.getString( i );
			if (content!=null) {
				fetch.put(rsdt.getColumnName(i), content);
    		}
			else {
				fetch.put(rsdt.getColumnName(i), "");
			}
		}
		return fetch;
	}
	return null;
}

public ResultSet mysql_query(Connection canal, String sql) throws SQLException
{
	PreparedStatement pstm = canal.prepareStatement(sql);
	ResultSet rst = pstm.executeQuery();
	return rst;
}

public String dame_def_tabla(Connection canal,String tabla,String salto) throws SQLException
{
	// Esquema de la tabla:
	String esquema = "";
    Hashtable fila = null;
    Hashtable indice = new Hashtable();

	esquema += "DROP TABLE IF EXISTS "+ tabla + ";" + salto;
    esquema += "CREATE TABLE "+ tabla +" ("+ salto;

	// Campos de la tabla - Tipos
    ResultSet tbl_prop_rst = mysql_query(canal, "SHOW FIELDS FROM " + tabla);
    while  ((fila = mysql_fetch_hashtable(tbl_prop_rst))!=null )
	{
		esquema += "   " + fila.get("Field") + " " + fila.get("Type");
		if (!fila.get("Default").equals("")) esquema += " DEFAULT '" + fila.get("Default") + "'";
        if (!fila.get("Null").equals("YES")) esquema += " NOT NULL";
        if (!fila.get("Extra").equals("")) esquema += " "+fila.get("Extra");
        esquema += ","+salto;
    }
	esquema = replaceLast(esquema,"," + salto ,"");

	// Claves de la tabla
    tbl_prop_rst = mysql_query(canal, "SHOW KEYS FROM " + tabla);
	while ((fila=mysql_fetch_hashtable(tbl_prop_rst))!=null )
	{
		String keyname = (String)fila.get("Key_name");
		if ( (!keyname.equals("PRIMARY") ) && (fila.get("Non_unique").equals("0"))) keyname="UNIQUE|"+keyname;
		if (indice.containsKey(keyname)==true) indice.put(keyname,(String)indice.get(keyname)+","+(String)fila.get("Column_name"));
		else indice.put(keyname,fila.get("Column_name"));
	}
    tbl_prop_rst.close();
    Enumeration en = indice.keys();
    while (en.hasMoreElements())
	{
        esquema += ","+salto;
        String key = (String)en.nextElement();
        if (key.equals("PRIMARY")) esquema += "   PRIMARY KEY (" + indice.get(key)+ ")";
        else if ((key.length()>7) && ((key.substring(0,6)).equals("UNIQUE"))) esquema += "   UNIQUE "+key.substring(7)+" (" +indice.get(key)+")";
        else esquema += "   KEY "+key+" (" + indice.get(key) + ")";
    }
    esquema += salto +")";

    return stripSlashes(esquema);
}

public String[] dame_ins_tabla(Connection canal, String tabla) throws SQLException
{
    ResultSet localrst = mysql_query(canal, "SELECT * FROM " + tabla);
    String[] insert = new String[mysql_num_rows(localrst)];
    ResultSetMetaData rsmd = localrst.getMetaData();
    String table_list="(";
    for(int i=1; i<=rsmd.getColumnCount(); i++) {
        table_list += rsmd.getColumnName(i)+", ";
    }
    table_list = replaceLast(table_list,", ","");
    table_list += ")";
    table_list = "INSERT INTO "+ tabla + " " +table_list+ " VALUES (";
    int count = 0;
    while (localrst.next()) {
            String schema_insert = "";
            for(int i=1; i<=rsmd.getColumnCount(); i++) {
                String row = localrst.getString(i);
                if (row==null) {
                    schema_insert += " NULL,";
                }
                else if (row.equals("")) {
                    schema_insert += " '',";
                }
                else {
                    schema_insert += " '"+addSlashes(row)+"',";
                }
            }
            schema_insert = replaceLast(schema_insert, ",","");
            insert[count]=table_list+schema_insert+");";
            count++;
    }
    localrst.close();
    return insert;
}
%>
