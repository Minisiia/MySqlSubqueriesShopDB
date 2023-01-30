/*
Используя вложенные запросы и ShopDB получить имена покупателей и имена сотрудников у которых 
TotalPrice товара больше 1000
*/

USE ShopDB;

/* Если речь идет о TotalPrice каждого наименования в заказе, то выборка записей будет пустая,
т.к. ни одна позиция в заказе в не имеет TotalPrice > 1000 */
SELECT
	(SELECT customers.LName FROM customers WHERE orders.CustomerNo = customers.CustomerNo) AS Customer_LName, 
	(SELECT customers.FName FROM customers WHERE orders.CustomerNo = customers.CustomerNo) AS Customer_FName,
	(SELECT customers.MName FROM customers WHERE orders.CustomerNo = customers.CustomerNo) AS Customer_MName,
	(SELECT employees.LName FROM employees WHERE orders.EmployeeID = employees.EmployeeID) AS Employee_LName, 
	(SELECT employees.FName FROM employees WHERE orders.EmployeeID = employees.EmployeeID) AS Employee_FName,
	(SELECT employees.MName FROM employees WHERE orders.EmployeeID = employees.EmployeeID) AS Employee_MName
FROM orders
WHERE orders.OrderID IN (SELECT orderdetails.OrderID FROM orderdetails WHERE orderdetails.TotalPrice>1000)
GROUP BY Customer_LName, Customer_FName, Customer_MName, Employee_LName, Employee_FName, Employee_MName;

/* Если речь идет о TotalPrice каждого заказа, то в выборке будет присутствовать только
одна запись - заказа с id 6, т.к. общая сумма заказа равна 1096*/
CREATE TEMPORARY TABLE TmpTable
SELECT 
	(SELECT customers.LName FROM customers WHERE customers.CustomerNo =
			(SELECT CustomerNo FROM orders WHERE orders.OrderID = OrderDetails.OrderID)) AS Customer_LName, 
	(SELECT customers.FName FROM customers WHERE customers.CustomerNo =
			(SELECT CustomerNo FROM orders WHERE orders.OrderID = OrderDetails.OrderID)) AS Customer_FName,
	(SELECT customers.MName FROM customers WHERE customers.CustomerNo =
			(SELECT CustomerNo FROM orders WHERE orders.OrderID = OrderDetails.OrderID)) AS Customer_MName,
	(SELECT employees.LName FROM employees WHERE employees.EmployeeID = 
			(SELECT EmployeeID FROM orders WHERE orders.OrderID = OrderDetails.OrderID)) AS Employee_LName, 
	(SELECT employees.FName FROM employees WHERE employees.EmployeeID = 
			(SELECT EmployeeID FROM orders WHERE orders.OrderID = OrderDetails.OrderID)) AS Employee_FName,
	(SELECT employees.MName FROM employees WHERE employees.EmployeeID = 
			(SELECT EmployeeID FROM orders WHERE orders.OrderID = OrderDetails.OrderID)) AS Employee_MName,
	orderdetails.TotalPrice AS Order_Sum
FROM orderdetails;

SELECT Customer_LName, Customer_FName, Customer_MName, Employee_LName, Employee_FName, Employee_MName, SUM(Order_Sum)  AS Order_Sum
FROM TmpTable
GROUP BY Customer_LName, Customer_FName, Customer_MName, Employee_LName, Employee_FName, Employee_MName
HAVING SUM(Order_Sum) > 1000;