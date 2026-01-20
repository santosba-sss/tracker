# Spring Boot Security JSP Example

## What you get
- Spring Boot (3.5.4)
- Spring Security with JPA-backed users
- JSP/JSTL views (login, index)
- Lombok in the model
- MySQL datasource (configure in `src/main/resources/application.properties`)

## Quick start
1. Install JDK 17+ and Maven.
2. Create a MySQL database `spring_security_demo` (or change the URL in application.properties).
3. Update `spring.datasource.username` and `spring.datasource.password` in `src/main/resources/application.properties`.
4. From project root run:
   ```
   mvn spring-boot:run
   ```
5. Default users auto-created:
   - username: `user` / password: `password` (ROLE_USER)
   - username: `admin` / password: `adminpass` (ROLE_ADMIN)

## Notes for NetBeans
- Import the generated pom.xml as a Maven project.
- Lombok requires the Lombok plugin installed in NetBeans (or enable annotation processing).

