<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="info.mask.title" /></title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<h2><fmt:message key="info.mask.list" /></h2>
<table><thead><tr><th>Bits (CIDR)</th><th><fmt:message key="common.table.mask" /></th></tr></thead>
<tbody>
<tr><td>1</td><td>128.0.0.0</td></tr>
<tr><td>2</td><td>192.0.0.0</td></tr>
<tr><td>3</td><td>224.0.0.0</td></tr>
<tr><td>4</td><td>240.0.0.0</td></tr>
<tr><td>5</td><td>248.0.0.0</td></tr>
<tr><td>6</td><td>252.0.0.0</td></tr>
<tr><td>7</td><td>254.0.0.0</td></tr>
<tr><td>8</td><td>255.0.0.0</td></tr>
<tr><td>9</td><td>255.128.0.0</td></tr>
<tr><td>10</td><td>255.192.0.0</td></tr>
<tr><td>11</td><td>255.224.0.0</td></tr>
<tr><td>12</td><td>255.240.0.0</td></tr>
<tr><td>13</td><td>255.248.0.0</td></tr>
<tr><td>14</td><td>255.252.0.0</td></tr>
<tr><td>15</td><td>255.254.0.0</td></tr>
<tr><td>16</td><td>255.255.0.0</td></tr>
<tr><td>17</td><td>255.255.128.0</td></tr>
<tr><td>18</td><td>255.255.192.0</td></tr>
<tr><td>19</td><td>255.255.224.0</td></tr>
<tr><td>20</td><td>255.255.240.0</td></tr>
<tr><td>21</td><td>255.255.248.0</td></tr>
<tr><td>22</td><td>255.255.252.0</td></tr>
<tr><td>23</td><td>255.255.254.0</td></tr>
<tr><td>24</td><td>255.255.255.0</td></tr>
<tr><td>25</td><td>255.255.255.128</td></tr>
<tr><td>26</td><td>255.255.255.192</td></tr>
<tr><td>27</td><td>255.255.255.224</td></tr>
<tr><td>28</td><td>255.255.255.240</td></tr>
<tr><td>29</td><td>255.255.255.248</td></tr>
<tr><td>30</td><td>255.255.255.252</td></tr>
<tr><td>31</td><td>255.255.255.254</td></tr>
<tr><td>32</td><td>255.255.255.255</td></tr>
</tbody></table></body></html>
