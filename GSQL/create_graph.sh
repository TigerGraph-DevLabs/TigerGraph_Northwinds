#!/bin/bash

gsql schema.gsql
gsql -g Northwind loading_jobs.gsql

gsql -g Northwind ./Queries/alphabetical_products.gsql
gsql -g Northwind ./Queries/get_all_order_subtotals.gsql
gsql -g Northwind ./Queries/get_current_product_list.gsql
gsql -g Northwind ./Queries/get_employee_sales_by_country.gsql
gsql -g Northwind ./Queries/get_order_details_extended.gsql
gsql -g Northwind ./Queries/get_order_subtotals.gsql
gsql -g Northwind ./Queries/get_sales_by_year.gsql
gsql -g Northwind ./Queries/sales_by_category.gsql