require 'sqlite3'

load 'db_functions.rb'

def get_info_from_mail(login_mail)

    db = connect_to_db("db/db.db")

    db.execute("SELECT * FROM users WHERE mail=?", [login_mail]).first
end