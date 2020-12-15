import pyodbc, os
import configparser
from flask import Flask, render_template, request, session, redirect, url_for
from datetime import datetime
from cryptography.fernet import Fernet

app = Flask(__name__)
app.secret_key = os.urandom(32)

config = configparser.ConfigParser()
config.read('superdesk.config')

encryptionKey = config['superdesk']['ENCRYPTIONKEY']
_driver = config['superdesk']['DRIVER']
_server = config['superdesk']['SERVER']
_port = config['superdesk']['PORT']
_database = config['superdesk']['DATABASE']
_username = config['superdesk']['UID']
_password = config['superdesk']['PWD']

#Establish database connection parameters
sqlconn = pyodbc.connect('DRIVER=%s;SERVER=%s;PORT=%s;DATABASE=%s;UID=%s;PWD=%s;' % ( _driver, _server, _port, _database, _username, _password))

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

            if account[8] == False:
                return render_template('index.html', msg='User is currently marked as inactive')
            else:
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

#New Ticket page
@app.route('/newticket', methods=['GET', 'POST'])
def newticket():
    if session:
        cursor = sqlconn.cursor()
        severityoptions = cursor.execute('SELECT name FROM [severity]').fetchall()
        typeoptions = cursor.execute('SELECT name FROM [type]').fetchall()

        if request.method == 'POST':
            now = datetime.now()
            description = now.strftime("%d/%m/%Y %H:%M:%S") + " - " + session['username'] + "\n" + request.form['description']
            cursor.execute('exec createNewTicket @userName=?, @title=?, @severityName=?, @typeName=?, @description=?', session['username'], request.form['title'], request.form['severity'], request.form['type'], description)
            sqlconn.commit()
            return render_template('index.html')
    else:
        return render_template('error.html')

    return render_template('newticket.html', typeoptions=typeoptions, severityoptions=severityoptions)

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
            if request.form['addcomment'] != "":
                change = True
                now = datetime.now()
                addcomment = now.strftime("%d/%m/%Y %H:%M:%S") + " - " + session['username'] + "\n" + request.form['addcomment'] + "\n \n" + request.form['description']
                cursor.execute('UPDATE [tickets] SET description = ? WHERE id = ?', addcomment, request.form['id'])
            if change == True:
                cursor.execute('exec updateTicketBy @ticketId = ?, @userName = ?', request.form['id'], session['username'])
            sqlconn.commit()
            ticketinfo = cursor.execute('exec getTicketInfo @ticketId = ?', id).fetchone()

        return render_template('ticketdetails.html', ticket=ticketinfo, statusoptions=statusoptions, severityoptions=severityoptions, typeoptions=typeoptions)
    else:
        return render_template('error.html')

#Admin page - Home
@app.route('/admin')
def admin():
    return render_template('admin.html')

#Admin page - New User Setup
@app.route('/admin/new/user', methods=['GET', 'POST'])
def admin_new_user():
    if session['admin'] == True:
        cursor = sqlconn.cursor()
        permissions = cursor.execute('SELECT name FROM [permission]').fetchall()

        if request.method == 'POST':
            cursor = sqlconn.cursor()
            cursor.execute('exec createNewUser @userName=?, @email=?, @firstName=?, @lastName=?, @phone=?, @permissions=?, @password=?', request.form['username'], request.form['email'], request.form['firstname'], request.form['lastname'], request.form['phone'], request.form['permissions'], pwEncrypt(request.form['password']))
            sqlconn.commit()
            return render_template('index.html')
    else:
        return render_template('error.html')

    return render_template('admin_new_user.html', permissions=permissions)

#Admin page - Edit Users
@app.route('/admin/edit/users', methods=['GET', 'POST'])
def admin_edit_users():
    if session['admin'] == True:
        cursor = sqlconn.cursor()
        getusernames = cursor.execute('SELECT id, username, firstname, lastname, email FROM [user]').fetchall()
    else:
        return render_template('error.html')

    return render_template('admin_edit_users.html', allusers=getusernames)

#Admin page - Edit Users - Details
@app.route('/admin/edit/users/<id>', methods=['GET', 'POST'])
def admin_edit_users_details(id):
    if session['admin'] == True:
        cursor = sqlconn.cursor()
        userinfo = cursor.execute('exec getUserInfo @userId=?', id).fetchone()
        permissions = cursor.execute('SELECT name FROM [permission]').fetchall()

        if request.method == 'POST':
            if request.form['email'] != userinfo[2]:
                cursor = sqlconn.cursor()
                cursor.execute('UPDATE [user] SET email = ? WHERE id = ?', request.form['email'], userinfo[0])
            if request.form['firstname'] != userinfo[3]:
                cursor = sqlconn.cursor()
                cursor.execute('UPDATE [user] SET firstname = ? WHERE id = ?', request.form['firstname'], userinfo[0])
            if request.form['lastname'] != userinfo[4]:
                cursor = sqlconn.cursor()
                cursor.execute('UPDATE [user] SET lastname = ? WHERE id = ?', request.form['lastname'], userinfo[0])
            if request.form['phone'] != userinfo[5]:
                cursor = sqlconn.cursor()
                cursor.execute('UPDATE [user] SET phone = ? WHERE id = ?', request.form['phone'], userinfo[0])
            if request.form['permissions'] != userinfo[6]:
                cursor.execute('UPDATE [user] SET [user].permissions = (SELECT id FROM permission WHERE name = ?) WHERE [user].id = ?', request.form['permissions'], request.form['id'])
            if request.form['active'] != userinfo[7]:
                cursor.execute('UPDATE [user] SET [user].active = ? WHERE id = ?', request.form['active'], request.form['id'])
            sqlconn.commit()
            return render_template('admin_edit_users.html', allusers=cursor.execute('SELECT id, username FROM [user]').fetchall())

        return render_template('admin_edit_users_details.html', user=userinfo, permissions=permissions)
    else:
        return render_template('error.html')

#Admin page - New Ticket Types
@app.route('/admin/new/types', methods=['GET', 'POST'])
def admin_new_ticket_types():
    if session['admin'] == True:
        if request.method == 'POST':
            cursor = sqlconn.cursor()
            cursor.execute('exec createNewTicketType @typename=?', request.form['typename'])
            sqlconn.commit()
            return render_template('admin_edit_ticket_types.html', alltypes=cursor.execute('SELECT id, name FROM [type]').fetchall())
    else:
        return render_template('error.html')

    return render_template('admin_new_ticket_types.html')

#Admin page - Edit Ticket Types
@app.route('/admin/edit/types', methods=['GET', 'POST'])
def admin_edit_ticket_types():
    if session['admin'] == True:
        cursor = sqlconn.cursor()
        gettickettypes = cursor.execute('SELECT id, name FROM [type]').fetchall()
    else:
        return render_template('error.html')

    return render_template('admin_edit_ticket_types.html', alltypes=gettickettypes)

#Admin page - Edit Ticket Types - Details
@app.route('/admin/edit/types/<id>', methods=['GET', 'POST'])
def admin_edit_types_details(id):
    cursor = sqlconn.cursor()
    typeinfo = cursor.execute('exec getTypeInfo @typeId=?', id).fetchone()

    if request.method == 'POST':
        if request.form['typename'] != typeinfo[1]:
            cursor = sqlconn.cursor()
            cursor.execute('UPDATE [type] SET name = ? WHERE id = ?', request.form['typename'], typeinfo[0])
        if request.form['active'] != typeinfo[2]:
            cursor = sqlconn.cursor()
            cursor.execute('UPDATE [type] SET [type].active = ? WHERE id = ?', request.form['active'], request.form['id'])
        sqlconn.commit()

        return render_template('admin_edit_ticket_types.html', alltypes=cursor.execute('SELECT id, name FROM [type]').fetchall())

    return render_template('admin_edit_type_details.html', type=typeinfo)

#Admin page - New Ticket Severity
@app.route('/admin/new/severity', methods=['GET', 'POST'])
def admin_new_ticket_sev():
    if session['admin'] == True:
        if request.method == 'POST':
            cursor = sqlconn.cursor()
            cursor.execute('exec createNewTicketSev @sevname=?', request.form['sevname'])
            sqlconn.commit()
            return render_template('admin_edit_ticket_sev.html', allsev=cursor.execute('SELECT id, name FROM [severity]').fetchall())
    else:
        return render_template('error.html')

    return render_template('admin_new_ticket_sev.html')

#Admin page - Edit Ticket Severity
@app.route('/admin/edit/severity', methods=['GET', 'POST'])
def admin_edit_ticket_sev():
    if session['admin'] == True:
        cursor = sqlconn.cursor()
        getticketsev = cursor.execute('SELECT id, name FROM [severity]').fetchall()
    else:
        return render_template('error.html')

    return render_template('admin_edit_ticket_sev.html', allsev=getticketsev)

#Admin page - Edit Ticket Severity - Details
@app.route('/admin/edit/severity/<id>', methods=['GET', 'POST'])
def admin_edit_sev_details(id):
    cursor = sqlconn.cursor()
    sevinfo = cursor.execute('exec getSevInfo @sevId=?', id).fetchone()

    if request.method == 'POST':
        if request.form['sevname'] != sevinfo[1]:
            cursor = sqlconn.cursor()
            cursor.execute('UPDATE [severity] SET name = ? WHERE id = ?', request.form['sevname'], sevinfo[0])
        if request.form['active'] != sevinfo[2]:
            cursor = sqlconn.cursor()
            cursor.execute('UPDATE [severity] SET [severity].active = ? WHERE id = ?', request.form['active'], request.form['id'])
        sqlconn.commit()

        return render_template('admin_edit_ticket_sev.html', allsev=cursor.execute('SELECT id, name FROM [severity]').fetchall())

    return render_template('admin_edit_sev_details.html', sev=sevinfo)

#Admin page - New Ticket Status
@app.route('/admin/new/status', methods=['GET', 'POST'])
def admin_new_ticket_status():
    if session['admin'] == True:
        if request.method == 'POST':
            cursor = sqlconn.cursor()
            cursor.execute('exec createNewTicketStatus @statusname=?', request.form['statusname'])
            sqlconn.commit()
            return render_template('admin_edit_ticket_status.html', allstatus=cursor.execute('SELECT id, name FROM [status]').fetchall())
    else:
        return render_template('error.html')

    return render_template('admin_new_ticket_status.html')

#Admin page - Edit Ticket Status
@app.route('/admin/edit/status', methods=['GET', 'POST'])
def admin_edit_ticket_status():
    if session['admin'] == True:
        cursor = sqlconn.cursor()
        getticketstatus = cursor.execute('SELECT id, name FROM [status]').fetchall()
    else:
        return render_template('error.html')

    return render_template('admin_edit_ticket_status.html', allstatus=getticketstatus)

#Admin page - Edit Ticket Status - Details
@app.route('/admin/edit/status/<id>', methods=['GET', 'POST'])
def admin_edit_status_details(id):
    cursor = sqlconn.cursor()
    statusinfo = cursor.execute('exec getStatusInfo @statusId=?', id).fetchone()

    if request.method == 'POST':
        if request.form['statusname'] != statusinfo[1]:
            cursor = sqlconn.cursor()
            cursor.execute('UPDATE [status] SET name = ? WHERE id = ?', request.form['statusname'], statusinfo[0])
        if request.form['active'] != statusinfo[2]:
            cursor = sqlconn.cursor()
            cursor.execute('UPDATE [status] SET [status].active = ? WHERE id = ?', request.form['active'], request.form['id'])
        sqlconn.commit()

        return render_template('admin_edit_ticket_status.html', allstatus=cursor.execute('SELECT id, name FROM [status]').fetchall())

    return render_template('admin_edit_status_details.html', status=statusinfo)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port='80')