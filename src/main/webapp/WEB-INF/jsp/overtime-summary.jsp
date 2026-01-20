<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Employee Summary</title>
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
        .card { background: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 24px; }
        table { width: 100%; border-collapse: collapse; }
        thead tr { border-bottom: 2px solid #e5e7eb; }
        th { text-align: left; padding: 12px 16px; font-weight: 600; color: #374151; }
        th.right { text-align: right; }
        th.center { text-align: center; }
        tbody tr { border-bottom: 1px solid #f3f4f6; }
        tbody tr:hover { background: #f9fafb; }
        td { padding: 16px; }
        td.right { text-align: right; }
        td.center { text-align: center; }
        tfoot tr { background: #f9fafb; border-top: 2px solid #d1d5db; font-weight: bold; }
        .badge { padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .badge-credit { background: #dbeafe; color: #1e40af; }
        .badge-deficit { background: #fee2e2; color: #991b1b; }
        .empty-state { text-align: center; padding: 60px 20px; color: #9ca3af; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>👥 All Employees Summary</h1>
                <p style="color: #6b7280; margin-top: 8px;">Overview of all employee overtime and PTL balances</p>
            </div>
            <div>
                <form method="get" style="display: inline-block; margin-right: 16px;">
                    <input type="month" name="month" value="${selectedMonth}" onchange="this.form.submit()" style="padding: 8px; border: 1px solid #d1d5db; border-radius: 6px;">
                </form>
                <a href="${pageContext.request.contextPath}/overtime" class="btn btn-primary">← Back to Tracker</a>
            </div>
        </div>

        <div class="card">
            <c:choose>
                <c:when test="${empty employees}">
                    <div class="empty-state">
                        <div style="font-size: 64px; margin-bottom: 16px;">👥</div>
                        <p>No employees added yet</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>Employee Name</th>
                                <th class="right">Total Overtime</th>
                                <th class="right">Total PTL Used</th>
                                <th class="right">Offset Balance</th>
                                <th class="right">Render Balance</th>
                                <th class="right">Total Leaves</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${employees}" var="emp">
                                <c:choose>
                                    <c:when test="${selectedYearMonth != null}">
                                        <c:set var="totalOT" value="${service.calculateMonthlyOT(emp, selectedYearMonth)}"/>
                                        <c:set var="totalPTL" value="${service.calculateMonthlyPTL(emp, selectedYearMonth)}"/>
                                        <c:set var="totalRender" value="${service.calculateMonthlyRender(emp, selectedYearMonth)}"/>
                                        <c:set var="totalOffsetUsed" value="${service.calculateMonthlyOffset(emp, selectedYearMonth)}"/>
                                        <c:set var="offset" value="${totalOT - totalOffsetUsed}"/>
                                        <c:set var="renderBalance" value="${totalPTL - totalRender}"/>
                                        <c:set var="totalLeaves" value="${service.calculateMonthlyLeaves(emp, selectedYearMonth)}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="totalOT" value="${service.calculateTotalOT(emp)}"/>
                                        <c:set var="totalPTL" value="${service.calculateTotalPTL(emp)}"/>
                                        <c:set var="offset" value="${service.calculateOffset(emp)}"/>
                                        <c:set var="renderBalance" value="${service.calculateRenderBalance(emp)}"/>
                                        <c:set var="totalLeaves" value="${service.calculateTotalLeaves(emp)}"/>
                                    </c:otherwise>
                                </c:choose>
                                <c:set var="otHours" value="${totalOT / 60}" />
                                <c:set var="otWholeHours" value="${otHours - (otHours % 1)}" />
                                <c:set var="ptlHours" value="${totalPTL / 60}" />
                                <c:set var="ptlWholeHours" value="${ptlHours - (ptlHours % 1)}" />
                                <c:set var="offsetHours" value="${Math.abs(offset) / 60}" />
                                <c:set var="offsetWholeHours" value="${offsetHours - (offsetHours % 1)}" />
                                <c:set var="renderHours" value="${Math.abs(renderBalance) / 60}" />
                                <c:set var="renderWholeHours" value="${renderHours - (renderHours % 1)}" />
                                <tr>
                                    <td style="font-weight: 500; color: #1f2937;">${emp.name}</td>
                                    <td class="right" style="color: #166534; font-weight: 500;"><fmt:formatNumber value="${otWholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${totalOT % 60} Mins</td>
                                    <td class="right" style="color: #9a3412; font-weight: 500;"><fmt:formatNumber value="${ptlWholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${totalPTL % 60} Mins</td>
                                    <td class="right" style="font-weight: bold; color: ${offset >= 0 ? '#1e40af' : '#991b1b'};">
                                        ${offset >= 0 ? '' : '-'}<fmt:formatNumber value="${offsetWholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${Math.abs(offset) % 60} Mins
                                    </td>
                                    <td class="right" style="font-weight: bold; color: ${renderBalance >= 0 ? '#1e40af' : '#991b1b'};">
                                        ${renderBalance >= 0 ? '' : '-'}<fmt:formatNumber value="${renderWholeHours}" maxFractionDigits="0" groupingUsed="false"/> Hours ${Math.abs(renderBalance) % 60} Mins
                                    </td>
                                    <td class="right" style="font-weight: 500; color: #854d0e;">${totalLeaves}</td>
                                </tr>
                            </c:forEach>
                        </tbody>

                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>
