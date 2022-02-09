# TigerGraph Northwinds

## Overview
This repo will give you two different methods for deploying the TigerGraph Northwinds demo. All operations in TigerGraph get distilled down to GSQL. Regardless of whether you are using the GSQL command line, GraphStudio interface, or an outside connector, the GSQL being executed is the same.

### GSQL Method
A series of Bash scripts will execute GSQL code to create the schema, load the data, and create the queries needed for the graph. This method will need to be executed on the TigerGraph server itself, or remotely via an exposed GSQL terminal. You can use the 'GSQL Access' feature of TigerGraph cloud to open a GSQL connection to your cloud Solution. Alternatively, you can use the [TigerGraph CLI](https://github.com/TigerGraph-DevLabs/TigerGraph-CLI) to interface with a cloud, or on-prem instance.

**To Set Up**

- Access the GSQL shell of your TigerGraph instance
- From within this repo, run: `cd GSQL`
- `bash create_graph.sh`
- `bash load_data.sh`
- If you wish to install the queries for REST access run: `bash install_queries.sh`

### Python Method
This Jupyter notebook contains blocks of [pyTigerGraph](https://pytigergraph.github.io/pyTigerGraph/) code that will connect to your TigerGraph solution, create a schema, create a graph, load your data, and allow you to run queries.

**To Set Up**

- Ensure you have a [Jupyter](https://jupyter.org/) environment accessible either locally, or in the cloud
- (Cloud Only) Clone this repository into your cloud environment using `git clone https://github.com/TigerGraph-DevLabs/TigerGraph_Northwinds.git`
- Navigate into the **Python** directory `cd ./Python`
- Start the notebook with `jupyter notebook setup.ipynb`
- Follow along with the notebook.

## Queries

<hr>

### All Order Subtotals
For each order calculate the subtotal based on:

**Quantity** of product * **Unit Price** of the product * (1 - **Discount**)

#### SQL
```sql
select OrderID, 
    format(sum(UnitPrice * Quantity * (1 - Discount)), 2) as Subtotal
from order_details
group by OrderID
order by OrderID;
```

#### GSQL
```gsql
SumAccum<FLOAT> @subtotal;
cust_orders = {CustomerOrder.*};
  
results = SELECT c FROM cust_orders:c - (contains_product:e) - Product
ACCUM
    c.@subtotal += e.unitPrice * e.quantity * (1.0 - e.discount);

PRINT results [results.@subtotal] AS results;
```
<hr>

### Sales by Year
Calculate subtotal for sales within the input year.

#### SQL
```sql
select distinct date(a.ShippedDate) as ShippedDate, 
    a.OrderID, 
    b.Subtotal, 
    year(a.ShippedDate) as Year
from Orders a 
inner join
(
    -- Get subtotal for each order
    select distinct OrderID, 
        format(sum(UnitPrice * Quantity * (1 - Discount)), 2) as Subtotal
    from order_details
    group by OrderID    
) b on a.OrderID = b.OrderID
where a.ShippedDate is not null
    and a.ShippedDate between date('1996-12-24') and date('1997-09-30')
order by a.ShippedDate;
```

#### GSQL

```gsql
CREATE QUERY get_sales_by_year(int in_year) FOR GRAPH Northwind { 

  SumAccum<FLOAT> @subtotal;
  cust_orders = {CustomerOrder.*};
  
  results = SELECT o FROM cust_orders:o - (contains_product:e) - Product
    WHERE
      year(o.shippedDate) == in_year
    ACCUM
      o.@subtotal += e.unitPrice * e.quantity * (1.0 - e.discount)
    ORDER BY
      o.shippedDate;
  
  PRINT results [results.shippedDate, results.@subtotal, year(results.shippedDate)];
}
```

<hr>

### Employee Sales by Country

#### SQL

```sql

```

#### GSQL

```gsql
CREATE QUERY get_employee_sales_by_country(VERTEX<Country> in_cont) FOR GRAPH Northwind SYNTAX v2{ 
  
  country = {in_cont};
  
  SumAccum<FLOAT> @subtotal;
  
  orders = SELECT o FROM country:c - (to_country) - CustomerOrder:o;
  
  subs = SELECT o FROM orders:o - (contains_product:e) - Product
    ACCUM
      o.@subtotal += e.unitPrice * e.quantity * (1.0 - e.discount);
    
  results = SELECT e FROM country:c - (to_country) - CustomerOrder:o - (facilitated_order) - Employee:e
    ACCUM
      e.@subtotal += o.@subtotal;
  
  PRINT country;
  PRINT results [results.firstName, results.lastName, results.@subtotal];
  
}
```

<hr>

### Alphabetical List of Products
Return a list of products in alphabetical order.

#### SQL

```sql
select ProductID, ProductName
from products
order by ProductName;
```

#### GSQL

```gsql
CREATE QUERY alphabetical_products() FOR GRAPH Northwind { 
  products = {Product.*};
  
  results = SELECT p FROM products:p
    ORDER BY
      p.productName ASC;
  
  PRINT results;
}
```

<hr>

### Current Products List
Return a list of products that are not discontinued.

#### SQL

```sql
select ProductID, ProductName
from products
where Discontinued = 'N'
order by ProductName;
```

#### GSQL

```gsql
CREATE QUERY get_current_product_list() FOR GRAPH Northwind { 
  products = {Product.*};
  
  results = SELECT p FROM products:p
    WHERE
      p.discontinued == FALSE
    ORDER BY
      p.productName ASC;
  
  PRINT results [results.id, results.productName];
}
```

### Order Details Extended
Return per-product detailed information about each order.

#### SQL
```sql
select distinct y.OrderID, 
    y.ProductID, 
    x.ProductName, 
    y.UnitPrice, 
    y.Quantity, 
    y.Discount, 
    round(y.UnitPrice * y.Quantity * (1 - y.Discount), 2) as ExtendedPrice
from Products x
inner join Order_Details y on x.ProductID = y.ProductID
order by y.OrderID;
```

#### GSQL
```gsql
CREATE QUERY get_order_details_extended() FOR GRAPH Northwind { 
  TYPEDEF TUPLE <INT product_id, STRING product_name, FLOAT unit_price, INT qty, FLOAT discnt, FLOAT ext_price> product_details;
  c_order = {CustomerOrder.*};
  
  MapAccum<VERTEX<Product>, product_details> @extended_price;
  
  results = SELECT o FROM c_order:o - (:e) - Product:p
    ACCUM
      FLOAT extended_price = e.unitPrice * e.quantity * (1 - e.discount),
      o.@extended_price += (p -> product_details(p.id, p.productName, e.unitPrice, e.quantity, e.discount, extended_price))
    ORDER BY
      o.id ASC;
  
  PRINT results [results.id, results.@extended_price];
}
```

<hr>

