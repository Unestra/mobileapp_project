# myapp
Asset booring system

Project Title: Asset Borrowing System

Objective: To create an efficient and user-friendly system for borrowing and returning sports equipment for students and staff at schools/universities.

Goals:

Reduce the time required for borrowing and returning sports equipment.

Increase the accuracy of managing borrowing and returning information.

Enable real-time monitoring of the status and availability of sports equipment.

Technologies Used:

Frontend: Dart, for developing a responsive and user-friendly interface.

Backend: Node.js, for server-side processing and database management.

Roles and Functions:

Borrower (Student):

Functions: Register/Login, Browse asset list, Request to borrow (specify borrowing and return dates), Check request status, View personal borrowing history.

Additional Details: A student can borrow only one asset per day. Requests can only be made for available assets. The borrowing date must be from today, and the return date must be today or later.

Lender (Lecturer):

Functions:

Browse asset list

Approve or disapprove borrowing requests

View personal borrowing history

Additional Details: If a request is approved, the asset's status changes to "Borrowed." If disapproved, the status remains "Available."

Staff:

Functions:

Add, edit, and disable assets

Receive returning assets and update the status to "Available"

View overall borrowing history

Dashboard showing the number of borrowed, available, and disabled assets each day

Additional Details: Staff can only disable assets that are currently "Available."

Dashboard:

Displays the number of borrowed, available, and disabled assets for the day.

Logout Functionality:

All roles have the ability to log out of the system.
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
