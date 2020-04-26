module Model

    require 'sqlite3'
    require 'bcrypt'

    #This functions makes it so I don't have to repeat myself in module with these two lines of code
    def connect_to_db(path) 
        db = SQLite3::Database.new(path)
        db.results_as_hash = true
        return db
    end 
    # Attempts to recieve information from a particular mail
    #
    # @option params [String] mail The e-mail
    #
    def get_info_from_mail(login_mail)

        db = connect_to_db("db/db.db")

        db.execute("SELECT * FROM users WHERE mail=?", [login_mail]).first
    end
    # Attempts to recieve all information from all users
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
    # Attempts to delete a user
    #
    # @option params [Integer] id The id of the user that will be deleted
    #
    def delete_user(id)

        db = connect_to_db("db/db.db")

        db.execute("DELETE FROM posts WHERE user_id = ?", id)
        
        db.execute("DELETE FROM users WHERE id = ?", id)

    end



    # Attempts to connect to a genre
    #
    # @option params [Integer] security The security clearance inside the company
    #
    def genre_info(genre)

        db = connect_to_db("db/db.db")
    
        db.execute("SELECT posts.title, posts.text, posts.id, posts.upvotes, genre.security, genre.name, users.name AS username, posts.user_id FROM genre LEFT JOIN posts ON genre.id = posts.genre LEFT JOIN users ON posts.user_id = users.id WHERE genre.name = ?", genre)
    
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