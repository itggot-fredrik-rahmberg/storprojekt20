require 'sqlite3'

load 'db_functions.rb'

def create_post(title, text, genre, id)

    db = connect_to_db("db/db.db")

    db.execute("INSERT INTO posts (title, text, genre, user_id) VALUES (?,?,?,?)", title, text, genre, id)

end

def delete_post(id)

    db = connect_to_db("db/db.db")

    db.execute("DELETE FROM posts WHERE id = ?", id)

end

def update_post(text, id)

    db = connect_to_db("db/db.db")

    db.execute("UPDATE posts SET text = ? WHERE id = ?", text, id)

end

def upvote(user_id, post_id)

    db = connect_to_db("db/db.db")

    result = db.execute("SELECT * FROM upvote WHERE user_id =? AND post_id =?", user_id, post_id)

    if result.length == 0
        db.execute("INSERT INTO upvote (user_id, post_id) VALUES (?,?)", user_id, post_id)
        db.execute("UPDATE posts SET upvotes = upvotes + 1 WHERE id = ?", post_id)

    end
end