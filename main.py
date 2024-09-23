import mysql.connector
import uuid
from faker import Faker
from dotenv import load_dotenv
import random
from datetime import datetime, timedelta
import os

# Load environment variables
load_dotenv()

# Connection settings
HOST = os.getenv('HOST', 'localhost')
USER = os.getenv('USER','root')
PASSWORD = os.getenv('PASSWORD','11032005m')
DATABASE = os.getenv('DATABASE','product_db')

# Connect to the MySQL database
connection = mysql.connector.connect(
    host=HOST,
    user=USER,
    password=PASSWORD,
    database=DATABASE
)

cursor = connection.cursor()
fake = Faker()

# Insert 100,000 rows into customers
print("Inserting into customers...")
customer_insert_query = """
    INSERT INTO customers (id, first_name, last_name, email, phone, address, city, status) 
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
"""
customers_data = [
    (str(uuid.uuid4()), fake.first_name(), fake.last_name(), fake.email(), fake.phone_number(), fake.address(), fake.city(), random.choice(['active', 'inactive']))
    for _ in range(100000)
]
cursor.executemany(customer_insert_query, customers_data)
connection.commit()
print("Inserted into customers.")

# Insert 1,000 rows into products
print("Inserting into products...")
product_insert_query = """
    INSERT INTO products (product_name, product_type, description, price, stock_quantity) 
    VALUES (%s, %s, %s, %s, %s)
"""
product_types = ['Type1', 'Type2', 'Type3', 'Type4', 'Type5']
products_data = [
    (fake.word(), random.choice(product_types), fake.text(), random.uniform(10.00, 1000.00), random.randint(0, 1000))
    for _ in range(1000)
]
cursor.executemany(product_insert_query, products_data)
connection.commit()
print("Inserted into products.")

# Insert 1,000,000 rows into orders
print("Inserting into orders...")
order_insert_query = """
    INSERT INTO orders (order_date, customer_id, product_id, quantity) 
    VALUES (%s, %s, %s, %s)
"""
order_date_start = datetime.now() - timedelta(days=365 * 5)
orders_data = [
    (order_date_start + timedelta(days=random.randint(0, 365 * 5)), random.choice(customers_data)[0], random.randint(1, 1000), random.randint(1, 10))
    for _ in range(1000000)
]
# Use chunks to avoid memory issues
chunk_size = 10000
for i in range(0, len(orders_data), chunk_size):
    cursor.executemany(order_insert_query, orders_data[i:i + chunk_size])
    connection.commit()
    print(f"Inserted {i + chunk_size} rows into orders...")

print("Inserted into orders.")

# Close the cursor and connection
cursor.close()
connection.close()