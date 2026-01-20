<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
    <title>ISD IV Overtime, PTL & Leave Tracker</title>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: system-ui, -apple-system, sans-serif; background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%); min-height: 100vh; padding: 20px; }
        .container { width: 95%; margin: 0 auto; }
        .header { background: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 24px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; }
        .header h1 { font-size: 28px; color: #312e81; }
        .btn { padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; font-weight: 500; text-decoration: none; display: inline-block; }
        .btn-primary { background: #4f46e5; color: white; }
        .btn-primary:hover { background: #4338ca; }
        .btn-success { background: #16a34a; color: white; }
        .btn-warning { background: #ea580c; color: white; }
        .btn-danger { background: #dc2626; color: white; padding: 6px 10px; }
        .grid { display: grid; grid-template-columns: 300px 1fr; gap: 24px; }
        .card { background: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 24px; }
        .card h2 { font-size: 20px; margin-bottom: 16px; color: #1f2937; }
        .input-group { display: flex; gap: 8px; margin-bottom: 16px; }
        input[type="text"], input[type="date"], input[type="time"], input[type="number"] { flex: 1; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px; }
        .employee-list { display: flex; flex-direction: column; gap: 8px; }
        .employee-btn { width: 100%; text-align: left; padding: 12px 16px; border: none; border-radius: 8px; cursor: pointer; background: #f3f4f6; color: #1f2937; font-weight: 500; font-size: 16px; }
        .employee-btn.active { background: #4f46e5; color: white; }
                        .stats { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; margin-bottom: 24px; }
        .stat-card { padding: 16px; border-radius: 8px; border: 2px solid; }
        .stat-card.green { background: #f0fdf4; border-color: #86efac; }
        .stat-card.orange { background: #fff7ed; border-color: #fdba74; }
        .stat-card.blue { background: #eff6ff; border-color: #93c5fd; }
        .stat-card.red { background: #fef2f2; border-color: #fca5a5; }
        .stat-label { font-size: 14px; color: #6b7280; margin-bottom: 4px; }
        .stat-value { font-size: 20px; font-weight: bold; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr 1fr; gap: 24px; margin-bottom: 24px; }
        .form-group { margin-bottom: 12px; }
        .form-group label { display: block; font-size: 14px; font-weight: 500; color: #374151; margin-bottom: 4px; }
        .records-grid { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr 1fr; gap: 24px; }
        .record-list { max-height: 300px; overflow-y: auto; }
        .record-item { background: #f9fafb; padding: 12px; border-radius: 8px; margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center; }
        .record-item.ot { background: #f0fdf4; }
        .record-item.ptl { background: #fff7ed; }
        .empty-state { text-align: center; padding: 60px 20px; color: #9ca3af; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>⏰ ISD IV Overtime, PTL & Leave Tracker</h1>
                <p style="color: #6b7280; margin-top: 8px;">Track employee overtime, permission to leave and leaves</p>
                <p style="color: #4f46e5; margin-top: 4px; font-weight: 500;">
                    Welcome, <sec:authorize access="authentication.name == 'admin'">
                                Nicky Lugtu
                            </sec:authorize>
                            <sec:authorize access="authentication.name != 'admin'">
                                <sec:authentication property="name"/>
                            </sec:authorize>
                    (<sec:authorize access="hasRole('ADMIN')">Administrator</sec:authorize><sec:authorize access="hasRole('USER')">Employee</sec:authorize>)
                </p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/overtime/summary" class="btn btn-primary">📊 View Summary</a>
                <a href="${pageContext.request.contextPath}/overtime/monthly" class="btn btn-primary" style="margin-left: 8px;">📅 Monthly Summary</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn" style="margin-left: 8px; background: #dc2626; color: white;">🚪 Logout</a>
            </div>
        </div>

        <div class="grid">
            <div class="card">
                <h2>👤 Employees</h2>
                <sec:authorize access="hasRole('ADMIN')">
                    <form action="${pageContext.request.contextPath}/overtime/employee/add" method="post">
                        <div class="input-group">
                            <input type="text" name="name" placeholder="Employee name" required>
                            <button type="submit" class="btn btn-primary">+</button>
                        </div>
                    </form>
                </sec:authorize>
                <div class="employee-list">
                    <c:forEach items="${employees}" var="emp">
                        <div style="display: flex; gap: 4px; align-items: center;">
                            <a href="${pageContext.request.contextPath}/overtime?selectedId=${emp.id}" style="text-decoration: none; flex: 1;">
                                <button type="button" class="employee-btn ${selectedEmployee != null && selectedEmployee.id == emp.id ? 'active' : ''}">${emp.name}</button>
                            </a>
                            <sec:authorize access="hasRole('ADMIN')">
                                <button type="button" class="btn btn-danger" onclick="confirmDelete('${emp.name}', '${pageContext.request.contextPath}/overtime/employee/delete/${emp.id}')">🗑</button>
                            </sec:authorize>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <div>
                <c:choose>
                    <c:when test="${selectedEmployee != null}">
                        <!-- Lunch Break Configuration -->
                        <div class="card" style="margin-bottom: 16px; padding: 16px;">
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <div>
                                    <h2 style="margin: 0; font-size: 16px;">🍽️ Lunch: ${selectedEmployee.lunchBreakStart} - ${selectedEmployee.lunchBreakEnd}</h2>
                                </div>
                                <sec:authorize access="hasRole('ADMIN')">
                                    <form action="${pageContext.request.contextPath}/overtime/employee/lunch-break/update" method="post" style="display: flex; gap: 4px; margin: 0;">
                                        <input type="hidden" name="employeeId" value="${selectedEmployee.id}">
                                        <input type="time" name="lunchStart" value="${selectedEmployee.lunchBreakStart}" style="padding: 4px; font-size: 12px; width: 100px;" required>
                                        <input type="time" name="lunchEnd" value="${selectedEmployee.lunchBreakEnd}" style="padding: 4px; font-size: 12px; width: 100px;" required>
                                        <button type="submit" class="btn btn-primary" style="padding: 4px 8px; font-size: 12px;">Update</button>
                                    </form>
                                </sec:authorize>
                            </div>
                        </div>
                        <div class="stats">
                            <div class="stat-card green">
                                <div class="stat-label">Total Overtime</div>
                                <c:set var="otHours" value="${totalOT / 60}" />
                                <c:set var="otWholeHours" value="${otHours - (otHours % 1)}" />
                                <div class="stat-value" style="color: #166534;">
                                    <fmt:formatNumber value="${otWholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${totalOT % 60} Mins
                                </div>
                            </div>
                            <div class="stat-card orange">
                                <div class="stat-label">Total PTL Used</div>
                                <c:set var="ptlHours" value="${totalPTL / 60}" />
                                <c:set var="ptlWholeHours" value="${ptlHours - (ptlHours % 1)}" />
                                <div class="stat-value" style="color: #9a3412;">
                                    <fmt:formatNumber value="${ptlWholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${totalPTL % 60} Mins
                                </div>
                            </div>
                            <div class="stat-card ${offset >= 0 ? 'blue' : 'red'}">
                                <div class="stat-label">Offset Balance</div>
                                <c:set var="offsetHours" value="${Math.abs(offset) / 60}" />
                                <c:set var="offsetWholeHours" value="${offsetHours - (offsetHours % 1)}" />
                                <div class="stat-value" style="color: ${offset >= 0 ? '#1e40af' : '#991b1b'};">
                                    ${offset >= 0 ? '' : '-'}<fmt:formatNumber value="${offsetWholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${Math.abs(offset) % 60} Mins
                                </div>
                            </div>
                            <div class="stat-card ${renderBalance >= 0 ? 'blue' : 'red'}">
                                <div class="stat-label">Render Balance</div>
                                <c:set var="renderHours" value="${Math.abs(renderBalance) / 60}" />
                                <c:set var="renderWholeHours" value="${renderHours - (renderHours % 1)}" />
                                <div class="stat-value" style="color: ${renderBalance >= 0 ? '#1e40af' : '#991b1b'};">
                                    ${renderBalance >= 0 ? '' : '-'}<fmt:formatNumber value="${renderWholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${Math.abs(renderBalance) % 60} Mins
                                </div>
                            </div>
                            <div class="stat-card" style="background: #fefce8; border-color: #fde047;">
                                <div class="stat-label">Total Leaves</div>
                                <div class="stat-value" style="color: #854d0e;">
                                    ${totalLeaves}
                                </div>
                            </div>
                        </div>

                        <sec:authorize access="hasRole('ADMIN')">
                            <div class="form-grid">
                                <div class="card">
                                    <h2>➕ Add Overtime</h2>
                                    <form action="${pageContext.request.contextPath}/overtime/overtime/add" method="post">
                                        <input type="hidden" name="employeeId" value="${selectedEmployee.id}">
                                        <div class="form-group">
                                            <label>Date</label>
                                            <input type="date" name="date" required>
                                        </div>
                                        <div class="form-group">
                                            <label>Start Time</label>
                                            <input type="time" name="time" required>
                                        </div>
                                        <div class="form-group">
                                            <label>End Time</label>
                                            <input type="time" name="endTime" required>
                                        </div>
                                        <button type="submit" class="btn btn-success" style="width: 100%;">Add Overtime</button>
                                    </form>
                                </div>

                                <div class="card">
                                    <h2>📅 Add PTL</h2>
                                    <form action="${pageContext.request.contextPath}/overtime/ptl/add" method="post">
                                        <input type="hidden" name="employeeId" value="${selectedEmployee.id}">
                                        <div class="form-group">
                                            <label>Date</label>
                                            <input type="date" name="date" required>
                                        </div>
                                        <div class="form-group">
                                            <label>Start Time</label>
                                            <input type="time" name="time" required>
                                        </div>
                                        <div class="form-group">
                                            <label>End Time</label>
                                            <input type="time" name="endTime" required>
                                        </div>
                                        <button type="submit" class="btn btn-warning" style="width: 100%;">Add PTL</button>
                                    </form>
                                </div>

                                <div class="card">
                                    <h2>⚡ Add Offset</h2>
                                    <form action="${pageContext.request.contextPath}/overtime/offset/add" method="post">
                                        <input type="hidden" name="employeeId" value="${selectedEmployee.id}">
                                        <div class="form-group">
                                            <label>Date</label>
                                            <input type="date" name="date" required>
                                        </div>
                                        <div class="form-group">
                                            <label>Start Time</label>
                                            <input type="time" name="time" required>
                                        </div>
                                        <div class="form-group">
                                            <label>End Time</label>
                                            <input type="time" name="endTime" required>
                                        </div>
                                        <button type="submit" class="btn" style="width: 100%; background: #0891b2; color: white;">Add Offset</button>
                                    </form>
                                </div>

                                <div class="card">
                                    <h2>🎨 Add Render</h2>
                                    <form action="${pageContext.request.contextPath}/overtime/render/add" method="post">
                                        <input type="hidden" name="employeeId" value="${selectedEmployee.id}">
                                        <div class="form-group">
                                            <label>Date</label>
                                            <input type="date" name="date" required>
                                        </div>
                                        <div class="form-group">
                                            <label>Start Time</label>
                                            <input type="time" name="time" required>
                                        </div>
                                        <div class="form-group">
                                            <label>End Time</label>
                                            <input type="time" name="endTime" required>
                                        </div>
                                        <button type="submit" class="btn" style="width: 100%; background: #7c3aed; color: white;">Add Render</button>
                                    </form>
                                </div>

                                <div class="card">
                                    <h2>🏖️ Add Leave</h2>
                                    <form action="${pageContext.request.contextPath}/overtime/leave/add" method="post">
                                        <input type="hidden" name="employeeId" value="${selectedEmployee.id}">
                                        <div class="form-group">
                                            <label>Start Date</label>
                                            <input type="date" name="startDate" required>
                                        </div>
                                        <div class="form-group">
                                            <label>End Date</label>
                                            <input type="date" name="endDate" required>
                                        </div>
                                        <div class="form-group">
                                            <label>Leave Type</label>
                                            <input type="text" name="leaveType" placeholder="e.g. Sick, Vacation" required>
                                        </div>
                                        <button type="submit" class="btn" style="width: 100%; background: #ca8a04; color: white;">Add Leave</button>
                                    </form>
                                </div>
                            </div>
                        </sec:authorize>

                        <div class="records-grid">
                            <div class="card">
                                <h2>Overtime Records</h2>
                                <div class="record-list">
                                    <c:choose>
                                        <c:when test="${empty selectedEmployee.overtimeRecords}">
                                            <p style="color: #9ca3af; font-size: 14px;">No overtime records</p>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${selectedEmployee.overtimeRecords}" var="record">
                                                <c:set var="hours" value="${record.minutes / 60}" />
                                                <c:set var="wholeHours" value="${hours - (hours % 1)}" />
                                                <div class="record-item ot">
                                                    <div>
                                                        <div style="font-weight: 500;">${record.date}</div>
                                                        <div style="font-size: 14px; color: #6b7280;">${record.time} - ${record.endTime} (<fmt:formatNumber value="${wholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${record.minutes % 60} Mins)</div>
                                                    </div>
                                                    <sec:authorize access="hasRole('ADMIN')">
                                                        <form action="${pageContext.request.contextPath}/overtime/overtime/delete/${record.id}" method="post" style="margin: 0;">
                                                            <input type="hidden" name="employeeId" value="${selectedEmployee.id}">
                                                            <button type="submit" class="btn btn-danger">🗑</button>
                                                        </form>
                                                    </sec:authorize>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="card">
                                <h2>PTL Records</h2>
                                <div class="record-list">
                                    <c:choose>
                                        <c:when test="${empty selectedEmployee.ptlRecords}">
                                            <p style="color: #9ca3af; font-size: 14px;">No PTL records</p>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${selectedEmployee.ptlRecords}" var="record">
                                                <c:set var="hours" value="${record.minutes / 60}" />
                                                <c:set var="wholeHours" value="${hours - (hours % 1)}" />
                                                <div class="record-item ptl">
                                                    <div>
                                                        <div style="font-weight: 500;">${record.date}</div>
                                                        <div style="font-size: 14px; color: #6b7280;">${record.time} - ${record.endTime} (<fmt:formatNumber value="${wholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${record.minutes % 60} Mins)</div>
                                                    </div>
                                                    <sec:authorize access="hasRole('ADMIN')">
                                                        <form action="${pageContext.request.contextPath}/overtime/ptl/delete/${record.id}" method="post" style="margin: 0;">
                                                            <input type="hidden" name="employeeId" value="${selectedEmployee.id}">
                                                            <button type="submit" class="btn btn-danger">🗑</button>
                                                        </form>
                                                    </sec:authorize>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="card">
                                <h2>Offset Records</h2>
                                <div class="record-list">
                                    <c:choose>
                                        <c:when test="${empty selectedEmployee.offsetRecords}">
                                            <p style="color: #9ca3af; font-size: 14px;">No offset records</p>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${selectedEmployee.offsetRecords}" var="record">
                                                <c:set var="hours" value="${record.minutes / 60}" />
                                                <c:set var="wholeHours" value="${hours - (hours % 1)}" />
                                                <div class="record-item" style="background: #ecfeff;">
                                                    <div>
                                                        <div style="font-weight: 500;">${record.date}</div>
                                                        <div style="font-size: 14px; color: #6b7280;">${record.time} - ${record.endTime} (<fmt:formatNumber value="${wholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${record.minutes % 60} Mins)</div>
                                                    </div>
                                                    <sec:authorize access="hasRole('ADMIN')">
                                                        <form action="${pageContext.request.contextPath}/overtime/offset/delete/${record.id}" method="post" style="margin: 0;">
                                                            <input type="hidden" name="employeeId" value="${selectedEmployee.id}">
                                                            <button type="submit" class="btn btn-danger">🗑</button>
                                                        </form>
                                                    </sec:authorize>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="card">
                                <h2>Render Records</h2>
                                <div class="record-list">
                                    <c:choose>
                                        <c:when test="${empty selectedEmployee.renderRecords}">
                                            <p style="color: #9ca3af; font-size: 14px;">No render records</p>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${selectedEmployee.renderRecords}" var="record">
                                                <c:set var="hours" value="${record.minutes / 60}" />
                                                <c:set var="wholeHours" value="${hours - (hours % 1)}" />
                                                <div class="record-item" style="background: #f5f3ff;">
                                                    <div>
                                                        <div style="font-weight: 500;">${record.date}</div>
                                                        <div style="font-size: 14px; color: #6b7280;">${record.time} - ${record.endTime} (<fmt:formatNumber value="${wholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${record.minutes % 60} Mins)</div>
                                                    </div>
                                                    <sec:authorize access="hasRole('ADMIN')">
                                                        <form action="${pageContext.request.contextPath}/overtime/render/delete/${record.id}" method="post" style="margin: 0;">
                                                            <input type="hidden" name="employeeId" value="${selectedEmployee.id}">
                                                            <button type="submit" class="btn btn-danger">🗑</button>
                                                        </form>
                                                    </sec:authorize>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="card">
                                <h2>Leave Records</h2>
                                <div class="record-list">
                                    <c:choose>
                                        <c:when test="${empty selectedEmployee.leaveRecords}">
                                            <p style="color: #9ca3af; font-size: 14px;">No leave records</p>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${selectedEmployee.leaveRecords}" var="record">
                                                <div class="record-item" style="background: #fefce8;">
                                                    <div>
                                                        <div style="font-weight: 500;">
                                                            <c:choose>
                                                                <c:when test="${record.startDate == record.endDate}">
                                                                    ${record.startDate}
                                                                </c:when>
                                                                <c:otherwise>
                                                                    ${record.startDate} - ${record.endDate}
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                        <div style="font-size: 14px; color: #6b7280;">${record.leaveType}</div>
                                                    </div>
                                                    <sec:authorize access="hasRole('ADMIN')">
                                                        <button type="button" class="btn btn-danger" onclick="confirmDelete('leave record', '${pageContext.request.contextPath}/overtime/leave/delete/${record.id}?employeeId=${selectedEmployee.id}')">🗑</button>
                                                    </sec:authorize>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="card empty-state">
                            <div style="font-size: 64px; margin-bottom: 16px;">👤</div>
                            <h3 style="font-size: 20px; color: #6b7280; margin-bottom: 8px;">No Employee Selected</h3>
                            <p>Add an employee or select one from the list to get started</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</body>
<script>
function confirmDelete(name, url) {
    Swal.fire({
        title: 'Delete ' + name + '?',
        text: 'This action cannot be undone!',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc2626',
        cancelButtonColor: '#6b7280',
        confirmButtonText: 'Yes, delete!'
    }).then((result) => {
        if (result.isConfirmed) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = url;
            document.body.appendChild(form);
            form.submit();
        }
    });
}
</script>
</html>
