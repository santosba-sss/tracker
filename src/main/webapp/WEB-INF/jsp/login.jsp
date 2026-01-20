<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <link rel="stylesheet" href="<c:url value='/css/styles.css'/>">
</head>
<body>
<div class="container">
    <h2>Sign in</h2>

    <form action="/login" method="post">
        <div>
            <label>Username</label>
            <input type="text" name="username" required/>
        </div>
        <div>
            <label>Password</label>
            <input type="password" name="password" required/>
        </div>
        <div>
            <button type="submit">Sign in</button>
        </div>
    </form>

    <c:if test="${param.error != null}">
        <p style="color:red">Invalid username or password.</p>
    </c:if>
    <c:if test="${param.logout != null}">
        <p style="color:green">You have been logged out.</p>
    </c:if>
</div>
</body>
</html>