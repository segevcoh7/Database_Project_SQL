# **Database Project - Travel Insurance System**  
📊 **Comprehensive Database Design, SQL Implementation, and Power BI Analysis**  

## **📌 Project Overview**  
This project focuses on designing and implementing a **relational database system** for a **travel insurance company**. It includes:  
✔ **Conceptual & Logical Database Design** (ERD Modeling)  
✔ **SQL Queries for Data Manipulation & Analysis**  
✔ **Data Cleaning & Processing** in **Excel**  
✔ **Power BI Dashboard** for visualization and reporting  

## **📂 Project Structure**  
Database_Project/ │── Data/ # Raw data files │ ├── excel full data.xlsx │── Description/ # Project summary & documentation │ ├── part 3.docx │── ERD/ # Entity-Relationship Design │ ├── part 1.docx │ ├── part 2.docx │ ├── part 2 - checked assignment.pdf │ ├── Part 3 - sql code and sheiltas.sql │── Power Bi/ # Power BI Visualizations │ ├── part 3 - power bi.pbix │── SQL/ # SQL Queries │ ├── Part3 - sql - insertion tables.sql │── README.md # Project documentation


## **🚀 Features & Deliverables**  
### **📌 ERD Design**  
- Created a conceptual **Entity-Relationship Diagram (ERD)** for the travel insurance system.  
- **Tables:** Customers, Passengers, Orders, Payments, Health Status, Insurances, Extra Insurances, etc.  
- Implemented **normalization** to ensure efficient database design.

### **🗄️ SQL Database Implementation**  
- Created tables using **SQL DDL (Data Definition Language)**.  
- Populated the database using **SQL DML (Data Manipulation Language)** queries.  
- Optimized **SQL queries** for performance.  
- Implemented **Stored Procedures, Joins, and Window Functions**.

### **📊 Power BI Dashboard**  
- Developed a **visual analytics dashboard** using Power BI.  
- Included key insights on **customer trends, risk analysis, and revenue metrics**.  
- **Dynamic filters** for interactive reporting.  

## **🛠️ Technologies Used**  
✔ **SQL Server / MySQL** (Database Design & Queries)  
✔ **Power BI** (Data Visualization & Business Intelligence)  
✔ **Excel** (Data Cleaning & Preprocessing)  

## **🔍 How to Use This Project?**  
### **1️⃣ Setting Up the Database**  
Run the following **SQL scripts** in **SQL Server / MySQL**:  
```sql
-- Creating Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(255),
    Email VARCHAR(255),
    Phone VARCHAR(20)
);

);
2️⃣ Running Queries
Use SQL queries from the SQL/ folder to:
✔ Retrieve customer records
✔ Analyze insurance claims
✔ Generate financial reports

3️⃣ Power BI Dashboard
Open Power BI Desktop.
Load the .pbix file from the Power Bi/ folder.
Refresh the data to analyze insights dynamically.
📌 Example SQL Queries
Retrieve all customers who have an active policy
SELECT c.CustomerID, c.FullName, o.order_id, o.dep_date, o.arriv_date
FROM Customers c
JOIN Orders o ON c.CustomerID = o.cus_Id
WHERE o.arriv_date > GETDATE();

📌 Future Enhancements
✅ Improve SQL query performance with indexing.
✅ Automate data updates in Power BI.
✅ Develop a web-based interface for the database.

📢 Contribution & Contact
📢 Feel free to fork this repository and contribute!
📧 Contact: segevcoh7@gmail.com | 🔗 LinkedIn | 📝 Portfolio

🚀 Happy Coding! 🎯

---

### **Instructions to Add This to Your GitHub Repository**
1. **Open your GitHub repository**.
2. Click **"Add file" > "Create new file"**.
3. Name the file **README.md**.
4. Copy and paste the above markdown code into the file.
5. Click **"Commit changes"**.

Your **GitHub repository** will now display a structured and professional **README.md** file with **proper formatting, SQL code examples, and project overview**! 🚀  

Let me know if you need any modifications! 😊
