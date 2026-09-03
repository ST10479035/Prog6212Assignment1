# Prog6212Assignment1
# RaceDay Event Management System

## 1. System Description
**RaceDay** is a comprehensive full-stack event management system designed to streamline race event creation, participant registration, and result tracking across various sporting categories (e.g., Road Running, Cycling, Trail Running). The platform provides a RESTful backend API integrated with a relational SQL database to ensure efficient user management, automated event enrolments, and post-event performance logging.

---

## 2. User Roles & Permissions
The system enforces Role-Based Access Control (RBAC) across two main user roles:

* **Organiser:**
  * **Description:** Administrative users responsible for managing the sporting events platform.
  * **Permissions:** Can create and manage event categories, schedule new sporting events, view participant enrolments, and upload/publish official race finish times and positions.

* **Participant:**
  * **Description:** General athletes and public users engaging with race events.
  * **Permissions:** Can view public race listings, browse event categories, register/enrol for upcoming events, view personal profile information, and check official event results.
