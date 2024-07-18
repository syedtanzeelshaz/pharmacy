import streamlit as st
import mysql.connector
import os

# Connect to MySQL database
conn = mysql.connector.connect(
    host='127.0.0.1',  
    user='root',  
    password='shinchan',  # Replace with your MySQL password
    database='ournewpharmacy'
)
cursor = conn.cursor()


def view_sales_history(barcode):
    cursor.execute('SELECT * FROM history_sales WHERE barcode = %s', (barcode,))
    sales_history = cursor.fetchall()
    return sales_history

# Function to retrieve drug and company information using a JOIN query
def get_drug_company_info():
    cursor.execute('''
        SELECT drugs.name, drugs.type, company.name 
        FROM drugs
        JOIN company ON drugs.company_name = company.name
    ''')
    info = cursor.fetchall()
    return info

# Function to retrieve drugs that are about to expire using a nested query
def get_expiring_drugs():
    cursor.execute('''
        SELECT name, expiration_date
        FROM drugs
        WHERE expiration_date < DATE_ADD(CURDATE(), INTERVAL 1 MONTH)
    ''')
    expiring_drugs = cursor.fetchall()
    return expiring_drugs

# Function to get the total sales for each drug using an aggregate query
def get_total_sales():
    cursor.execute('''
        SELECT name, SUM(quantity) 
        FROM history_sales 
        GROUP BY name
    ''')
    total_sales = cursor.fetchall()
    return total_sales


st.title('Pharmacy Management System-Staff Page')

def add_purchase(barcode, quantity):
    cursor.execute('SELECT * FROM drugs WHERE barcode = %s', (barcode,))
    drug = cursor.fetchone()

    if drug:
        if drug[12] >= quantity:  # Check if there is enough quantity in stock
            amount = quantity * drug[6]  # Calculate the amount based on selling price
            cursor.execute('INSERT INTO purchase (barcode, name, type, company_name, quantity, price, amount) VALUES (%s, %s, %s, %s, %s, %s, %s)',
                           (drug[2], drug[0], drug[1], drug[8], quantity, drug[6], amount))
            # Update quantity in the "drugs" table
            cursor.execute('UPDATE drugs SET quantity = quantity - %s WHERE barcode = %s', (quantity, barcode))
            # Update quantity in the "history_sales" table
            cursor.execute('INSERT INTO history_sales (user_name, barcode, name, type, dose, quantity, price, amount, date, time) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, CURDATE(), CURTIME())',
                           ('Staff', drug[2], drug[0], drug[1], drug[3], quantity, drug[6], amount))
            conn.commit()
            st.success('Purchase added successfully!')
        else:
            st.warning(f'Not enough stock available for {drug[0]}. Available quantity: {drug[12]}')
    else:
        st.warning(f'No drug found with barcode: {barcode}')



st.title('Pharmacy Management System - Staff Page')
st.header('Add Purchase')

barcode_purchase = st.text_input('Enter Barcode for Purchase')
quantity_purchase = st.number_input('Enter Quantity for Purchase', min_value=1, value=1)
if st.button('Add Purchase'):
    add_purchase(barcode_purchase, quantity_purchase)

st.header('View Sales History')
barcode = st.text_input('Enter Barcode to View Sales History')

if st.button('View Sales History'):
    sales_history = view_sales_history(barcode)
    if sales_history:
        st.write('Sales History:')
        st.dataframe(sales_history)
    else:
        st.warning('No sales history found for the given barcode.')

# View Drug and Company Info Section
st.header('View Drug and Company Info')
if st.button('View Info'):
    info = get_drug_company_info()
    if info:
        st.write('Drug and Company Info:')
        st.dataframe(info)
    else:
        st.warning('No information found.')

# View Expiring Drugs Section
st.header('View Expiring Drugs')
if st.button('View Expiring Drugs'):
    expiring_drugs = get_expiring_drugs()
    if expiring_drugs:
        st.write('Expiring Drugs:')
        st.dataframe(expiring_drugs)
    else:
        st.warning('No expiring drugs found.')

# View Total Sales Section
st.header('View Total Sales')
if st.button('View Total Sales'):
    total_sales = get_total_sales()
    if total_sales:
        st.write('Total Sales:')
        st.table(total_sales)
    else:
        st.warning('No sales found.')
