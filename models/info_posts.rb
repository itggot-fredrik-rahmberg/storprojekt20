require 'sqlite3'

load 'db_functions.rb'

def create_post(title, text, genre, op)

    db = connect_to_db("db/db.db")

    db.execute("INSERT INTO posts (title, text, genre, op) VALUES (?,?,?,?)", title, text, genre, op)

end

def enter_genre(genre)

    db = connect_to_db("db/db.db")

    db.execute("SELECT posts.*, users.name FROM posts LEFT JOIN users ON posts.user_id = users.id WHERE genre = ?", genre)

end

def delete_post(id)

    db = connect_to_db("db/db.db")

    db.execute("DELETE FROM posts WHERE id = ?", id)

end

def update_post(text, id)

    db = connect_to_db("db/db.db")

    db.execute("UPDATE posts SET text = ? WHERE id = ?", text, id)

end