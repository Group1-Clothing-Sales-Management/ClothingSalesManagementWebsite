<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="page-heading-block">
    <span class="page-title-icon" aria-hidden="true">
        <i class="<c:out value="${param.icon}"/>"></i>
    </span>
    <div class="page-heading-copy">
        <h1 class="page-title" title="<c:out value="${param.title}"/>"><c:out value="${param.title}"/></h1>
        <c:if test="${not empty param.subtitle}">
            <p class="page-subtitle" title="<c:out value="${param.subtitle}"/>"><c:out value="${param.subtitle}"/></p>
        </c:if>
    </div>
</div>