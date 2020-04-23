module Model

    require 'sqlite3'
    require 'bcrypt'


    load 'db_functions.rb'

    def get_info_from_mail(login_mail)

        db = connect_to_db("db/db.db")

        db.execute("SELECT * FROM users WHERE mail=?", [login_mail]).first
    end

    def get_all_info_from_user()

        db = connect_to_db("db/db.db")

        db.execute("SELECT * FROM users")
    end
    # Attempts to create a new user
    #
    # @option params [String] name The name of the employee
    # @option params [String] mail The e-mail
    # @option params [String] password_digest The password
    # @option params [String] rank The company position
    # @option params [Integer] security The security clearance inside the company
    #
    def create_user(name, password_digest, rank, security, mail)

        db = connect_to_db("db/db.db")

        db.execute("INSERT INTO users (name, password, rank, security_level, mail) VALUES (?,?,?,?,?)", name, password_digest, rank, security, mail)

    end

    def delete_user(id)

        db = connect_to_db("db/db.db")

        if db.execute("SELECT * FROM posts WHERE id = ?", id).length != 0
            db.execute("DELETE FROM posts WHERE user_id = ?", id)
        end
        
        db.execute("DELETE FROM users WHERE id = ?", id)

    end





    def genre_info(genre)

        db = connect_to_db("db/db.db")
    
        db.execute("SELECT posts.title, posts.text, posts.id, posts.upvotes, genre.security, genre.name AS genre FROM genre LEFT JOIN posts ON genre.id = posts.genre LEFT JOIN users ON posts.user_id = users.id WHERE genre.name = ?", genre)
    
    end





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


    def login(password_digest)
        return BCrypt::Password.new(password_digest)
    end
    
    def digest(password)
        return BCrypt::Password.create(password)
    end


end