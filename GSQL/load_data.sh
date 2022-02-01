#!/bin/bash

gsql -g Northwind "RUN LOADING JOB load_job_categories USING MyDataSource=../data/categories.csv"
gsql -g Northwind "RUN LOADING JOB load_job_customers USING MyDataSource=../data/customers.csv"
gsql -g Northwind "RUN LOADING JOB load_job_employee_territories USING MyDataSource=../data/employee_territories.csv"
gsql -g Northwind "RUN LOADING JOB load_job_order_details USING MyDataSource=../data/order_details.csv"
gsql -g Northwind "RUN LOADING JOB load_job_employees USING MyDataSource=../data/employees.csv"
gsql -g Northwind "RUN LOADING JOB load_job_orders USING MyDataSource=../data/orders.csv"
gsql -g Northwind "RUN LOADING JOB load_job_products USING MyDataSource=../data/products.csv"
gsql -g Northwind "RUN LOADING JOB load_job_regions USING MyDataSource=../data/regions.csv"
gsql -g Northwind "RUN LOADING JOB load_job_shippers USING MyDataSource=../data/shippers.csv"
gsql -g Northwind "RUN LOADING JOB load_job_suppliers USING MyDataSource=../data/suppliers.csv"
gsql -g Northwind "RUN LOADING JOB load_job_territories USING MyDataSource=../data/territories.csv"