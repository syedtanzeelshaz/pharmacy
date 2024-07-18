# login.py
import streamlit as st
import mysql.connector
import subprocess

# Connect to MySQL database
conn = mysql.connector.connect(
    host='127.0.0.1',  
    user='root',  
    password='shinchan',  # Replace with your MySQL password
    database='ournewpharmacy'
)
cursor = conn.cursor()

# Function to authenticate user
def authenticate_user(name, password):
    cursor.execute('SELECT * FROM users WHERE name = %s AND password = %s', (name, password))
    user = cursor.fetchone()
    return user

# Streamlit UI
st.title('Pharmacy Management System - Login')

# Login Section
user_name = st.text_input('User Name')
user_password = st.text_input('Password', type='password')

if st.button('Login'):
    user = authenticate_user(user_name, user_password)
    if user:
        st.success(f'Welcome, {user[1]}!')
        st.session_state.logged_in = True
        st.session_state.user_id = user[0]
        user_role = user[7]

        # Redirect based on user role
        if user_role == 'admin':
            subprocess.run(["streamlit", "run", "project1.py"])
        elif user_role == 'staff':
            subprocess.run(["streamlit", "run", "project2.py"])
        else:
            st.error('Invalid role. Please contact the administrator.')

    else:
        st.error('Invalid credentials. Please try again.')

# Close the connection
cursor.close()
conn.close()
