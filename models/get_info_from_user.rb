require 'sqlite3'

load 'db_functions.rb'

def get_info_from_mail(login_mail)

    db = connect_to_db("db/db.db")

    db.execute("SELECT * FROM users WHERE mail=?", [login_mail]).first
end

def get_all_info_from_user()

    db = connect_to_db("db/db.db")

    db.execute("SELECT * FROM users")
end

def create_user(name, password_digest, rank, security, mail)

    db = connect_to_db("db/db.db")

    db.execute("INSERT INTO users (name, password, rank, security_level, mail) VALUES (?,?,?,?,?)", name, password_digest, rank, security, mail)

end

def delete_user(id)

    db = connect_to_db("db/db.db")

    if db.execute("SELECT * FROM posts WHERE id = ?", id).length != 0
        #delete all posts where user_id
    end
    
    db.execute("DELETE FROM users WHERE id = ?", id)

end