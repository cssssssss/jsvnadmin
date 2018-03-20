<%@ page contentType="text/html;charset=UTF-8"%>
<%@page import="org.svnadmin.util.SpringUtils"%>
<%@page import="org.svnadmin.util.I18N"%>
<%@page import="org.svnadmin.service.UsrService"%>
<%@page import="java.io.*"%>
<html>
<%
response.setHeader("Cache-Control", "no-cache, post-check=0, pre-check=0");
response.setHeader("Pragma", "no-cache");
response.setHeader("Expires", "Thu, 01 Dec 1970 16:00:00 GMT");

String ctx = request.getContextPath();
UsrService usrService = SpringUtils.getBean(UsrService.BEAN_NAME);
//验证是否连接上数据库 @see Issue 12
try{
	usrService.validatConnection();
}catch(Exception e){
	StringWriter sWriter = new StringWriter();
	PrintWriter pWriter = new PrintWriter(sWriter);
	e.printStackTrace(pWriter);
	out.println("Could not connect to database."
			+"<br>连接数据库失败!请确认数据库已经正确建立,并正确配置WEB-INF/jdbc.properties连接参数"
			+"<br><br><div style='color:red;'>" +sWriter.toString()+"</div>");
	return;
}
%>
<head>
	<title><%=I18N.getLbl(request, "login.title", "SVN ADMIN 登录")%></title>
	<script type="text/javascript">
	window.onload=function(){
		document.getElementById("usr").focus();
	}
	</script>
</head>
<body>
<%-- 选择语言 --%>
<div style="float:right;height:10%" >
	<%@include file="chagelang.jsp"%>
</div>


<%-- login form --%>
	
	    <table style="width:100%;height:90%;" cellspacing="0" cellpadding="0" border="0" class="login_bg">
	     <tr style="height:20%"><td align="center" >
            <h1><%=I18N.getLbl(request,"main.title","SVN MANAGER")%></h1>
        </td>
        </tr>
        <%-- error --%>
		<%
		String errorMsg = (String)request.getAttribute(org.svnadmin.Constants.ERROR);
		if(errorMsg != null){
		%>
		 <tr><td align="center" >
		<font style="color:red;"><%=I18N.getLbl(request,"sys.error","错误") %> <%=errorMsg%></font>
		</td>
        </tr>
		<%}%>
		<%-- set administrator tip --%> 
		<%
		int usrCount = usrService.getCount();
		if(usrCount == 0){
		%>
		 <tr><td align="center" >
		<font style="color:blue;"><%=I18N.getLbl(request,"login.info.setadmin","欢迎使用SVN ADMIN,第一次使用请设置管理员帐号和密码.") %></font>
			</td>
        </tr>
		<%}%>
        <tr style="height:80%">
            <td valign="top" align="center" >
                <table width="489" cellspacing="0" cellpadding="0" border="0">
                    <tr>
                        <td valign="bottom" style="height:247px" class="login_pic01">
                            <table width="360" cellspacing="0" cellpadding="0" border="0">
                                <tr>
                                    <td style="width:10px;height:51px;">&nbsp;</td>
                                    <td style="width:390px"></td>
                                </tr>
                            </table>
                            <table cellspacing="0" cellpadding="0" border="0" align="center">
                             <form name="login" action="<%=ctx%>/login" method="post">
                                <tr style="width:93px; height:50px;" >
                                    <td style="width:93px; height:50px;" align="right"><%=I18N.getLbl(request,"usr.usr","帐号") %> ：</td>
                                    <td style="width:227px;">
                                       <input type="text" id="usr" name="usr" value="<%=request.getParameter("usr")==null?"":request.getParameter("usr")%>">
                                    </td>
                                </tr>
                                <tr style="width:93px; height:50px;" >
                                    <td style="height:50px;" align="right"><%=I18N.getLbl(request,"usr.psw","密码") %>：</td>
                                    <td>
                                      <input type="password" id="psw" name="psw" value="<%=request.getParameter("psw")==null?"":request.getParameter("psw")%>">
                                    </td>
                                </tr>
                                
                                <tr style="width:93px; height:50px;" >
                                    <td align="center" colspan="3">
                                        <table cellspacing="0" cellpadding="0" border="0" class="fm_table_left">
                                            <tr>
                                                <td >
                                                   <input type="submit" value="<%=I18N.getLbl(request,"login.btn.login","登录") %>" style="height:25px;width:100px;">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                               </form>
                            </table>
                            <table width="100%" cellspacing="0" cellpadding="0" border="0">
                                <tbody>
                                    <tr>
                                        <td style="width:120px;"></td>
                                        <td style="height:22px;color: red;"></td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top" style="height:137px;" class="login_pic02">&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        
    </table>
</body>
</html>