#!/bin/bash

gsql schema.gsql
gsql -g Northwind loading_jobs.gsql

gsql ./Queries/alphabetical_products.gsql
gsql ./Queries/get_all_order_subtotals.gsql
gsql ./Queries/get_current_product_list.gsql
gsql ./Queries/get_employee_sales_by_country.gsql
gsql ./Queries/get_order_details_extended.gsql
gsql ./Queries/get_order_subtotals.gsql
gsql ./Queries/get_sales_by_year.gsql
gsql ./Queries/sales_by_category.gsql