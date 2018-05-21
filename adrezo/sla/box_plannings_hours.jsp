<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.rezo && !empty param.id && param.id > 0}">
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="sla.planning.box.title" /> ${param.id}</title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<jsp:useBean id="testHours" scope="page" class="ypodev.adrezo.beans.TestHoursBean" />
<sql:query var="hours">select * from slaplanning where id = ${param.id}</sql:query>
<h2><fmt:message key="sla.planning.box.title" /><fmt:message key="common.space" />${param.id} - ${param.name}</h2>
<div><fmt:message key="sla.planning.box.reminder" /> :</div>
<hr />
<form action="" id="fList">
<table id="plan_table">
<thead><tr><th><fmt:message key="common.day" /></th><th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th><th>11</th><th>12</th><th>13</th><th>14</th><th>15</th><th>16</th><th>17</th><th>18</th><th>19</th><th>20</th><th>21</th><th>22</th><th>23</th><th /></tr></thead>
<tbody>
<c:forEach items="${hours.rows}" var="hour">
<tr><td><input type="hidden" value="1" /><fmt:message key="common.days.monday" /></td><c:set target="${testHours}" property="hours" value="${hour.h1}" />
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour0}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour1}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour2}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour3}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour4}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour5}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour6}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour7}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour8}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour9}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour10}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour11}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour12}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour13}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour14}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour15}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour16}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour17}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour18}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour19}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour20}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour21}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour22}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d1" value="true" <c:if test='${testHours.hour23}'> checked="true"</c:if> /></td>
<td><a href="javascript:HoursBox('d1',true,false)"><fmt:message key="common.all" /></a> <a href="javascript:HoursBox('d1',false,false)"><fmt:message key="common.none" /></a> <a href="javascript:HoursBox('d1',true,true)"><fmt:message key="common.invert" /></a></td>
</tr>
<tr><td><input type="hidden" value="2" /><fmt:message key="common.days.tuesday" /></td><c:set target="${testHours}" property="hours" value="${hour.h2}" />
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour0}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour1}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour2}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour3}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour4}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour5}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour6}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour7}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour8}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour9}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour10}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour11}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour12}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour13}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour14}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour15}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour16}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour17}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour18}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour19}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour20}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour21}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour22}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d2" value="true" <c:if test='${testHours.hour23}'> checked="true"</c:if> /></td>
<td><a href="javascript:HoursBox('d2',true,false)"><fmt:message key="common.all" /></a> <a href="javascript:HoursBox('d2',false,false)"><fmt:message key="common.none" /></a> <a href="javascript:HoursBox('d2',true,true)"><fmt:message key="common.invert" /></a></td>
</tr>
<tr><td><input type="hidden" value="3" /><fmt:message key="common.days.wednesday" /></td><c:set target="${testHours}" property="hours" value="${hour.h3}" />
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour0}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour1}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour2}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour3}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour4}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour5}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour6}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour7}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour8}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour9}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour10}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour11}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour12}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour13}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour14}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour15}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour16}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour17}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour18}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour19}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour20}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour21}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour22}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d3" value="true" <c:if test='${testHours.hour23}'> checked="true"</c:if> /></td>
<td><a href="javascript:HoursBox('d3',true,false)"><fmt:message key="common.all" /></a> <a href="javascript:HoursBox('d3',false,false)"><fmt:message key="common.none" /></a> <a href="javascript:HoursBox('d3',true,true)"><fmt:message key="common.invert" /></a></td>
</tr>
<tr><td><input type="hidden" value="4" /><fmt:message key="common.days.thursday" /></td><c:set target="${testHours}" property="hours" value="${hour.h4}" />
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour0}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour1}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour2}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour3}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour4}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour5}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour6}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour7}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour8}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour9}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour10}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour11}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour12}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour13}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour14}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour15}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour16}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour17}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour18}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour19}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour20}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour21}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour22}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d4" value="true" <c:if test='${testHours.hour23}'> checked="true"</c:if> /></td>
<td><a href="javascript:HoursBox('d4',true,false)"><fmt:message key="common.all" /></a> <a href="javascript:HoursBox('d4',false,false)"><fmt:message key="common.none" /></a> <a href="javascript:HoursBox('d4',true,true)"><fmt:message key="common.invert" /></a></td>
</tr>
<tr><td><input type="hidden" value="5" /><fmt:message key="common.days.friday" /></td><c:set target="${testHours}" property="hours" value="${hour.h5}" />
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour0}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour1}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour2}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour3}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour4}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour5}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour6}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour7}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour8}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour9}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour10}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour11}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour12}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour13}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour14}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour15}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour16}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour17}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour18}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour19}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour20}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour21}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour22}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d5" value="true" <c:if test='${testHours.hour23}'> checked="true"</c:if> /></td>
<td><a href="javascript:HoursBox('d5',true,false)"><fmt:message key="common.all" /></a> <a href="javascript:HoursBox('d5',false,false)"><fmt:message key="common.none" /></a> <a href="javascript:HoursBox('d5',true,true)"><fmt:message key="common.invert" /></a></td>
</tr>
<tr><td><input type="hidden" value="6" /><fmt:message key="common.days.satursday" /></td><c:set target="${testHours}" property="hours" value="${hour.h6}" />
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour0}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour1}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour2}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour3}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour4}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour5}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour6}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour7}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour8}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour9}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour10}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour11}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour12}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour13}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour14}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour15}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour16}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour17}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour18}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour19}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour20}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour21}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour22}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d6" value="true" <c:if test='${testHours.hour23}'> checked="true"</c:if> /></td>
<td><a href="javascript:HoursBox('d6',true,false)"><fmt:message key="common.all" /></a> <a href="javascript:HoursBox('d6',false,false)"><fmt:message key="common.none" /></a> <a href="javascript:HoursBox('d6',true,true)"><fmt:message key="common.invert" /></a></td>
</tr>
<tr><td><input type="hidden" value="7" /><fmt:message key="common.days.sunday" /></td><c:set target="${testHours}" property="hours" value="${hour.h7}" />
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour0}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour1}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour2}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour3}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour4}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour5}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour6}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour7}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour8}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour9}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour10}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour11}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour12}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour13}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour14}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour15}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour16}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour17}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour18}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour19}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour20}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour21}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour22}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" name="d7" value="true" <c:if test='${testHours.hour23}'> checked="true"</c:if> /></td>
<td><a href="javascript:HoursBox('d7',true,false)"><fmt:message key="common.all" /></a> <a href="javascript:HoursBox('d7',false,false)"><fmt:message key="common.none" /></a> <a href="javascript:HoursBox('d7',true,true)"><fmt:message key="common.invert" /></a></td>
</tr>
</c:forEach>
<tr><td colspan="25" style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:PlanValid(event,${param.id})" /></span></td></tr>
</tbody></table>
</form>
</body></html>
<c:remove var="testHours" scope="page"/>
</c:if>
