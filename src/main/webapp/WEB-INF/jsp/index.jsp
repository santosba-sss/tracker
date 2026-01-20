<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Home</title>
    <link rel="stylesheet" href="<c:url value='/css/styles.css'/>">
</head>
<body>
<div class="container">
    <h1>Welcome, <c:out value="${username}"/>!</h1>

    <p>This is a minimal Spring Boot + Security + JSP skeleton.</p>

    <sec:authorize access="isAuthenticated()">
        <form action="<c:url value='/logout'/>" method="post">
            <sec:csrfInput/>
            <button type="submit">Logout</button>
        </form>
    </sec:authorize>

    <sec:authorize access="!isAuthenticated()">
        <a href="<c:url value='/login'/>">Login</a>
    </sec:authorize>
</div>
</body>
</html>