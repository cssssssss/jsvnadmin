<%@ page contentType="text/html;charset=UTF-8"%>
<%@page import="org.svnadmin.Constants"%>
<%@page import="org.svnadmin.util.I18N"%>
<%@include file="header.jsp"%>
<div style="width:100%;text-align:center">
<span style="color:green;font-weight:bold;"><%=I18N.getLbl(request,"usr.title","用户管理") %></span><br><br>
</div>
<%
boolean hasAdminRight = (Boolean)request.getAttribute("hasAdminRight");
%>

<%
org.svnadmin.entity.Usr entity = (org.svnadmin.entity.Usr)request.getAttribute("entity");
if(entity==null)entity=new org.svnadmin.entity.Usr();
%>
<script>
function checkForm(f){
	if(f.elements["usr"].value==""){
		alert("<%=I18N.getLbl(request,"usr.error.usr","用户不可以为空") %>");
		f.elements["usr"].focus();
		return false;
	}
	if(f.elements["psw"].value==""  && f.elements["newPsw"]!=null && f.elements["newPsw"].value==""){
		alert("<%=I18N.getLbl(request,"usr.error.psw","密码不可以为空") %>");
		f.elements["psw"].focus();
		return false;
	}
	return true;
}
</script>
<form name="usr" action="<%=ctx%>/usr" method="post" onsubmit="return checkForm(this);">
	<input type="hidden" name="act" value="save">
	<table class="thinborder" style="margin-left:10%;width:80%">
		<tr>
			<td class="lbl" ><%=I18N.getLbl(request,"usr.usr","用户") %></td>
			<td>
				<%if(hasAdminRight){ %>
					<input type="text" name="usr" value="<%=entity.getUsr()==null?"":entity.getUsr()%>" 
					onkeyup="value=value.replace(/[^._\-A-Za-z0-9*]/g,'')">
					<span style="color:red;">*</span>
				<%}else{ %>
				   	<input type="hidden" name="usr" value="<%=entity.getUsr()==null?"":entity.getUsr()%>" >
				   	<%=entity.getUsr()==null?"":entity.getUsr()%>
				<%} %>				
			</td>
			
			<td class="lbl"><%=I18N.getLbl(request,"usr.name","姓名") %></td>
			<td>
				<input type="text" name="name" value="<%=entity.getName()==null?"":entity.getName()%>">
			</td>
			
			<td class="lbl"><%=I18N.getLbl(request,"usr.psw","密码") %></td>
			<td>
			<input type="password" name="newPsw" value="">
			<input type="hidden" name="psw" value="<%=entity.getPsw()==null?"":entity.getPsw()%>">
			</td>
			
			<%if(hasAdminRight){ %>
			<td class="lbl"><%=I18N.getLbl(request,"usr.role","角色") %></td>
			<td>
				<select name="role">
					<option value=""><%=I18N.getLbl(request,"usr.role.select","选择角色") %></option>
					<option value="<%=Constants.USR_ROLE_ADMIN%>" <%=Constants.USR_ROLE_ADMIN.equals(entity.getRole())?"selected='selected'":""%>>admin</option>
				</select>
			</td>
			<%} %>
			<td>
				<input type="submit" value="<%=I18N.getLbl(request,"usr.op.submit","提交") %>">
			</td>
		</tr>
	</table>
</form>

<%if(hasAdminRight){ %>

<table class="sortable thinborder" style="margin-left:10%;width:80%"> 

	<thead>
		<td style="width:5%"><%=I18N.getLbl(request,"sys.lbl.no","NO.") %></td>
		<td style="width:15%"><%=I18N.getLbl(request,"usr.usr","用户") %></td>
		<td style="width:15%"><%=I18N.getLbl(request,"usr.name","姓名") %></td>
		<td style="width:20%"><%=I18N.getLbl(request,"usr.psw","密码") %></td>
		<td style="width:15%"><%=I18N.getLbl(request,"usr.role","角色") %></td>
		<td style="width:15%"><%=I18N.getLbl(request,"usr.op.delete","删除") %></td>
		<td style="width:15%"><%=I18N.getLbl(request,"usr.op.listauth","查看权限") %></td>
	</thead>
	<%
	java.util.List<org.svnadmin.entity.Usr> list = (java.util.List<org.svnadmin.entity.Usr>)request.getAttribute("list");

	if(list!=null){
		int no = 1;	  
		for(int i = 0;i<list.size();i++){
		  org.svnadmin.entity.Usr usr = list.get(i);
		  if("*".equals(usr.getUsr())){
			  continue;
		  }
		%>
		<tr>
		<td align="center"><%=(no++) %></td>
		<td align="center" style="word-break:break-all ;white-space:normal;">
			<a href="<%=ctx%>/usr?act=get&usr=<%=usr.getUsr()%>"><%=usr.getUsr() %></a>
		</td>
		<td align="center" style="word-break:break-all ;white-space:normal;"><%=usr.getName()==null?"":usr.getName() %></td>
		<td align="center" style="word-break:break-all ;white-space:normal;"><%="******" %></td>
		<td align="center" style="word-break:break-all ;white-space:normal;"><%=usr.getRole()==null?"":usr.getRole() %></td>
		<td align="center" style="word-break:break-all ;white-space:normal;"><a href="javascript:if(confirm('<%=I18N.getLbl(request,"usr.op.delete.confirm","确认删除?") %>')){del('<%=ctx%>/usr?usr=<%=usr.getUsr()%>')}"><%=I18N.getLbl(request,"usr.op.delete","删除") %></a></td>
		<td align="center" style="word-break:break-all ;white-space:normal;"><a href="<%=ctx%>/usr?act=searchAuth&usr=<%=usr.getUsr()%>"><%=I18N.getLbl(request,"usr.op.listauth","查看权限") %></a></td>
	</tr>
		<%	
	}}
	%>
</table>
<%} %>

<%
java.util.List<org.svnadmin.entity.PjAuth> auths = (java.util.List<org.svnadmin.entity.PjAuth>)request.getAttribute("auths");

if(auths!=null){
%>
<br>
<div style="width:100%;text-align:center">
<span style="color:green;font-weight:bold;"><%=I18N.getLbl(request,"usr.op.listauth","查看权限") %></span><br><br>
</div>
<table class="sortable thinborder" style="margin-left:10%;width:80%">

	<thead> 
		
		<td style="width:5%"><%=I18N.getLbl(request,"sys.lbl.no","NO.") %></td>
		<td style="width:10%"><%=I18N.getLbl(request,"pj.pj","项目") %></td>
		<td style="width:10%"><%=I18N.getLbl(request,"usr.usr","用户") %></td>
		<td style="width:40%"><%=I18N.getLbl(request,"pjauth.res","资源") %></td>
		<td style="width:25%"><%=I18N.getLbl(request,"pj.des","描述") %></td>
		<td style="width:10%"><%=I18N.getLbl(request,"pjauth.rw","权限") %></td>
	</thead>
	<%
		int no = 1;	  
		for(int i = 0;i<auths.size();i++){
		  org.svnadmin.entity.PjAuth auth = auths.get(i);
		%>
		<tr>
		<td align="center"><%=(no++) %></td>
		<td align="center" style="word-break:break-all ;white-space:normal;"><%=auth.getPj()%></td>
		<td align="center" style="word-break:break-all ;white-space:normal;"><%=auth.getUsr()%></td>
		<td align="center" style="word-break:break-all ;white-space:normal;"><%=auth.getRes().replace(auth.getPj()+":",auth.getUrl()).replace("[","").replace("]","")%></td>
		<td align="center" style="word-break:break-all ;white-space:normal;"><%=auth.getDes()%></td>
		<td align="center" style="word-break:break-all ;white-space:normal;">
			<% if("r".equals(auth.getRw())){ %>
				<%=I18N.getLbl(request,"pjauth.rw.r","可读") %>
			<%}else if("rw".equals(auth.getRw())){%>
				<%=I18N.getLbl(request,"pjauth.rw.rw","可读可写") %>
			<%}else{%>
				<%=I18N.getLbl(request,"pjauth.rw.none","没有权限") %>
			<%}%>
		</td>
	</tr>
		<%	
	}
	%>
</table>

<%	
}
%>