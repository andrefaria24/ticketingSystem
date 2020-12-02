import pyodbc, os
from flask import Flask, render_template, request, session, redirect, url_for
from cryptography.fernet import Fernet

app = Flask(__name__, static_url_path='/static')
app.secret_key = os.urandom(32)

encryptionKey = 'AXO74KhnXdkcJIBZSd6dvxlaFaVjDb7sIfftbZJNnnY='

#Establish database connection parameters
sqlconn = pyodbc.connect('DRIVER=FreeTDS;SERVER=database_host;PORT=1433;DATABASE=superdesk;UID=superdesk;PWD=superdesk;TDS_Version=8.0;')

#Password encryption logic
def pwEncrypt(pw):
    f = Fernet(encryptionKey)

    encodedPw = pw.encode()
    encryptedPw = f.encrypt(encodedPw)

    return encryptedPw

#Password decryption logic
def pwDecrypt(pw):
    f = Fernet(encryptionKey)

    encodedPw = pw.encode()
    decryptedPw = f.decrypt(encodedPw)

    return decryptedPw.decode()

#Home page
@app.route('/', methods=['GET', 'POST'])
def home():
    #Login session logic
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        username = request.form['username']
        password = request.form['password']

        cursor = sqlconn.cursor()

        dbPw = cursor.execute('SELECT password FROM [user] WHERE username = ?',username).fetchone()

        encDbPw = pwDecrypt(dbPw[0])

        if encDbPw == password:
            cursor.execute('SELECT * FROM [user] WHERE username = ?', username)
            account = cursor.fetchone()

            session['loggedin'] = True
            session['id'] = account[0]
            session['username'] = account[1]
            session['permissions'] = account[7]

            if account[7] == 1:
                session['admin'] = True
            else:
                session['admin'] = False

            return render_template('index.html')
        else:
            return render_template('index.html', msg='Incorrect Username/Password')
    else:
        return render_template('index.html')

#Logout page
@app.route('/logout')
def logout():
    #Clear session and redirect user back to login screen
    session.pop('loggedin', None)
    session.pop('id', None)
    session.pop('username', None)

    return redirect(url_for('home'))

#Tickets page
@app.route('/tickets')
def tickets():
    #If a session is established retreive and display ticket information
    if session:
        cursor = sqlconn.cursor()
        alltickets = cursor.execute('getAllTickets').fetchall()
        mytickets = cursor.execute('getMyOpenTickets @userId = ?', session['id']).fetchall()

        return render_template('tickets.html', alltickets=alltickets, mytickets=mytickets)
    else:
        return render_template('error.html')

#Ticket detail page
@app.route('/ticket/<id>/details/', methods=['GET', 'POST'])
def ticketdetails(id):
    if session:
        cursor = sqlconn.cursor()
        ticketinfo = cursor.execute('exec getTicketInfo @ticketId = ?', id).fetchone()
        statusoptions = cursor.execute('SELECT name FROM [status]').fetchall()
        severityoptions = cursor.execute('SELECT name FROM [severity]').fetchall()
        typeoptions = cursor.execute('SELECT name FROM [type]').fetchall()
    else:
        return render_template('error.html')

    if request.method == 'POST':
        change = False
        if request.form['severity'] != ticketinfo[8]:
            change = True
            cursor.execute('exec updateTicketSeverity @ticketId = ?, @severityName = ?', request.form['id'], request.form['severity'])
        if request.form['type'] != ticketinfo[9]:
            change = True
            cursor.execute('exec updateTicketType @ticketId = ?, @typeName = ?', request.form['id'], request.form['type'])
        if request.form['status'] != ticketinfo[6]:
            change = True
            cursor.execute('exec updateTicketStatus @ticketId = ?, @statusName = ?', request.form['id'], request.form['status'])
        if request.form['description'] != ticketinfo[7]:
            change = True
            cursor.execute('UPDATE [tickets] SET description = ? WHERE id = ?', request.form['description'], request.form['id'])
        if change == True:
            cursor.execute('exec updateTicketBy @ticketId = ?, @userName = ?', request.form['id'], session['username'])
    sqlconn.commit()
    ticketinfo = cursor.execute('exec getTicketInfo @ticketId = ?', id).fetchone()

    return render_template('ticketdetails.html', ticket=ticketinfo, statusoptions=statusoptions, severityoptions=severityoptions, typeoptions=typeoptions)

#Settings page
@app.route('/settings', methods=['GET', 'POST'])
def settings():
    #Fetch and display user information from database
    cursor = sqlconn.cursor()
    cursor.execute('SELECT * FROM [user] WHERE username = ?', (session['username']))
    userinfo = cursor.fetchone()

    #If any changes are detected, update database tables accordingly
    if request.method == 'POST':
        if request.form['firstname'] != userinfo[4]:
            cursor.execute('UPDATE [user] SET firstname = ? WHERE id = ?', request.form['firstname'], session['id'])
        if request.form['lastname'] != userinfo[5]:
            cursor.execute('UPDATE [user] SET lastname = ? WHERE id = ?', request.form['lastname'], session['id'])
        if request.form['email'] != userinfo[3]:
            cursor.execute('UPDATE [user] SET email = ? WHERE id = ?', request.form['email'], session['id'])
        if request.form['phone'] != userinfo[6]:
            cursor.execute('UPDATE [user] SET phone = ? WHERE id = ?', request.form['phone'], session['id'])

        if (request.form['newpassword'] != '') and (request.form['newpassword'] == request.form['confpassword']):
            cursor.execute('UPDATE [user] SET password = ? WHERE id = ?', pwEncrypt(request.form['newpassword']), session['id'])
            sqlconn.commit()
            return logout()
        elif (request.form['newpassword'] != '') and (request.form['newpassword'] != request.form['confpassword']):
            print("PASSWORDS MUST MATCH")
        sqlconn.commit()

        cursor.execute('SELECT * FROM [user] WHERE username = ?', (session['username']))
        userinfo = cursor.fetchone()

    return render_template('settings.html', userinfo=userinfo)

#New ticket page
@app.route('/newticket', methods=['GET', 'POST'])
def newticket():
    if session:
        cursor = sqlconn.cursor()
        severityoptions = cursor.execute('SELECT name FROM [severity]').fetchall()
        typeoptions = cursor.execute('SELECT name FROM [type]').fetchall()
    else:
        return render_template('error.html')

    if request.method == 'POST':
        cursor.execute('exec createNewTicket @userName=?, @title=?, @severityName=?, @typeName=?, @description=?', session['username'], request.form['title'], request.form['severity'], request.form['type'], request.form['description'])
        sqlconn.commit()
        return render_template('index.html')
        
    return render_template('newticket.html', typeoptions=typeoptions, severityoptions=severityoptions)

#Admin page
@app.route('/admin')
def admin():
    return render_template('admin.html')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port='80')