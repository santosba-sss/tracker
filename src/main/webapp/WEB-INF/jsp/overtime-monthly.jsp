<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Monthly Summary</title>
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: system-ui, -apple-system, sans-serif; background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%); min-height: 100vh; padding: 20px; }
        .container { width: 95%; margin: 0 auto; }
        .header { background: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 24px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; }
        .header h1 { font-size: 28px; color: #312e81; }
        .btn { padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; font-weight: 500; text-decoration: none; display: inline-block; }
        .btn-primary { background: #4f46e5; color: white; }
        .btn-primary:hover { background: #4338ca; }
        .card { background: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 24px; margin-bottom: 24px; }
        .employee-list { display: flex; gap: 8px; margin-bottom: 24px; flex-wrap: wrap; }
        .employee-btn { padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; background: #f3f4f6; color: #1f2937; font-weight: 500; text-decoration: none; display: inline-block; }
        .employee-btn.active { background: #4f46e5; color: white; }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        thead tr { border-bottom: 2px solid #e5e7eb; background: #f9fafb; }
        th { text-align: center; padding: 10px 8px; font-weight: 600; color: #374151; white-space: nowrap; border: 1px solid #e5e7eb; }
        th:first-child { text-align: left; position: sticky; left: 0; background: #f9fafb; z-index: 10; }
        tbody tr { border-bottom: 1px solid #f3f4f6; }
        tbody tr:nth-child(odd) { background: #ffffff; }
        tbody tr:nth-child(even) { background: #f9fafb; }
        tbody tr:hover { background: #e0e7ff; }
        td { padding: 10px 8px; text-align: center; font-size: 12px; border: 1px solid #e5e7eb; }
        td:first-child { text-align: left; font-weight: 600; position: sticky; left: 0; z-index: 5; background: inherit; }
        tbody tr:nth-child(1) td:first-child { background: #f0fdf4; color: #166534; }
        tbody tr:nth-child(2) td:first-child { background: #fff7ed; color: #9a3412; }
        tbody tr:nth-child(3) td:first-child { background: #ecfeff; color: #0e7490; }
        tbody tr:nth-child(4) td:first-child { background: #f5f3ff; color: #6b21a8; }
        tbody tr:nth-child(5) td:first-child { background: #fefce8; color: #854d0e; }
        tbody tr:nth-child(1) td { color: #166534; }
        tbody tr:nth-child(2) td { color: #9a3412; }
        tbody tr:nth-child(3) td { color: #0e7490; }
        tbody tr:nth-child(4) td { color: #6b21a8; }
        tbody tr:nth-child(5) td { color: #854d0e; }
        .table-wrapper { overflow-x: auto; }
        .empty-state { text-align: center; padding: 60px 20px; color: #9ca3af; }
        .dataTables_wrapper { padding: 20px 0; }
        .dataTables_filter input { padding: 8px; border: 1px solid #d1d5db; border-radius: 6px; }
        .dataTables_length select { padding: 6px; border: 1px solid #d1d5db; border-radius: 6px; }
        .dataTables_filter, .dataTables_length, .dataTables_info, .dataTables_paginate { display: none !important; }
    </style>
    <script>
        $(document).ready(function() {
            $('table[id^="monthlyTable"]').DataTable({
                scrollX: true,
                paging: false,
                ordering: false,
                searching: false,
                info: false
            });
        });
    </script>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>📅 Monthly Summary</h1>
                <p style="color: #6b7280; margin-top: 8px;">Daily records by type</p>
            </div>
            <div style="display: flex; gap: 12px; align-items: center;">
                <input type="month" id="monthSelector" value="${selectedMonth}" style="padding: 10px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 14px;">
                <a href="${pageContext.request.contextPath}/overtime" class="btn btn-primary">← Back to Tracker</a>
            </div>
        </div>
        <script>
            document.getElementById('monthSelector').addEventListener('change', function() {
                const month = this.value;
                const urlParams = new URLSearchParams(window.location.search);
                urlParams.set('month', month);
                window.location.search = urlParams.toString();
            });
        </script>

        <div class="card">
            <h2 style="margin-bottom: 16px;">Select Employee</h2>
            <div class="employee-list">
                <a href="${pageContext.request.contextPath}/overtime/monthly?view=all" class="employee-btn ${viewAll ? 'active' : ''}">All Employees</a>
                <c:forEach items="${employees}" var="emp">
                    <a href="${pageContext.request.contextPath}/overtime/monthly?selectedId=${emp.id}" class="employee-btn ${selectedEmployee != null && selectedEmployee.id == emp.id ? 'active' : ''}">${emp.name}</a>
                </c:forEach>
            </div>
        </div>

        <c:choose>
            <c:when test="${viewAll}">
                <c:forEach items="${allEmployeesData}" var="empData">
                    <div class="card">
                        <h2 style="margin-bottom: 16px;">${empData.employeeName} - Monthly Records</h2>
                        <div class="table-wrapper">
                            <table id="monthlyTable_${empData.employeeName}">
                                <thead>
                                    <tr>
                                        <th>Record Type</th>
                                        <c:forEach items="${empData.dates}" var="date">
                                            <th>
                                                <fmt:parseDate value="${date}" pattern="yyyy-MM-dd" var="parsedDate"/>
                                                <fmt:formatDate value="${parsedDate}" pattern="MM/dd/yyyy"/>
                                            </th>
                                        </c:forEach>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>Overtime</td>
                                        <c:forEach items="${empData.dates}" var="date">
                                            <td style="${not empty empData.overtime[date] ? 'background: #f0fdf4;' : ''}">${empData.overtime[date]}</td>
                                        </c:forEach>
                                    </tr>
                                    <tr>
                                        <td>PTL</td>
                                        <c:forEach items="${empData.dates}" var="date">
                                            <td style="${not empty empData.ptl[date] ? 'background: #fff7ed;' : ''}">${empData.ptl[date]}</td>
                                        </c:forEach>
                                    </tr>
                                    <tr>
                                        <td>Offset</td>
                                        <c:forEach items="${empData.dates}" var="date">
                                            <td style="${not empty empData.offset[date] ? 'background: #ecfeff;' : ''}">${empData.offset[date]}</td>
                                        </c:forEach>
                                    </tr>
                                    <tr>
                                        <td>Render</td>
                                        <c:forEach items="${empData.dates}" var="date">
                                            <td style="${not empty empData.render[date] ? 'background: #f5f3ff;' : ''}">${empData.render[date]}</td>
                                        </c:forEach>
                                    </tr>
                                    <tr>
                                        <td>Leave</td>
                                        <c:forEach items="${empData.dates}" var="date">
                                            <td style="${not empty empData.leave[date] ? 'background: #fefce8;' : ''}">${empData.leave[date]}</td>
                                        </c:forEach>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:when test="${selectedEmployee != null}">
                <div class="card">
                    <h2 style="margin-bottom: 16px;">${selectedEmployee.name} - Monthly Records</h2>
                    <c:choose>
                        <c:when test="${empty monthlyData.dates}">
                            <div class="empty-state">
                                <p>No records for this employee</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-wrapper">
                                <table id="monthlyTable">
                                    <thead>
                                        <tr>
                                            <th>Record Type</th>
                                            <c:forEach items="${monthlyData.dates}" var="date">
                                                <th>
                                                    <fmt:parseDate value="${date}" pattern="yyyy-MM-dd" var="parsedDate"/>
                                                    <fmt:formatDate value="${parsedDate}" pattern="MM/dd/yyyy"/>
                                                </th>
                                            </c:forEach>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Overtime</td>
                                            <c:forEach items="${monthlyData.dates}" var="date">
                                                <td style="${not empty monthlyData.overtime[date] ? 'background: #f0fdf4;' : ''}">${monthlyData.overtime[date]}</td>
                                            </c:forEach>
                                        </tr>
                                        <tr>
                                            <td>PTL</td>
                                            <c:forEach items="${monthlyData.dates}" var="date">
                                                <td style="${not empty monthlyData.ptl[date] ? 'background: #fff7ed;' : ''}">${monthlyData.ptl[date]}</td>
                                            </c:forEach>
                                        </tr>
                                        <tr>
                                            <td>Offset</td>
                                            <c:forEach items="${monthlyData.dates}" var="date">
                                                <td style="${not empty monthlyData.offset[date] ? 'background: #ecfeff;' : ''}">${monthlyData.offset[date]}</td>
                                            </c:forEach>
                                        </tr>
                                        <tr>
                                            <td>Render</td>
                                            <c:forEach items="${monthlyData.dates}" var="date">
                                                <td style="${not empty monthlyData.render[date] ? 'background: #f5f3ff;' : ''}">${monthlyData.render[date]}</td>
                                            </c:forEach>
                                        </tr>
                                        <tr>
                                            <td>Leave</td>
                                            <c:forEach items="${monthlyData.dates}" var="date">
                                                <td style="${not empty monthlyData.leave[date] ? 'background: #fefce8;' : ''}">${monthlyData.leave[date]}</td>
                                            </c:forEach>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card">
                    <div class="empty-state">
                        <div style="font-size: 64px; margin-bottom: 16px;">👤</div>
                        <p>Select an employee to view monthly records</p>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>
