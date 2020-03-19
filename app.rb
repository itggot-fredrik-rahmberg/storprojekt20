require'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'

require_relative 'models/get_info_from_user.rb'

load 'db_functions.rb'

enable :sessions

#This checks if the user is signed in everytime they change route.
before do 
    if (session[:id] ==  nil) && (request.path_info != '/') && (request.path_info != '/login' && (request.path_info != '/users/error')) 
      redirect("/")
    end
end
#This checks if you have done an error
def set_error(error)
    session[:error] = error
end

get("/users/error") do
    slim(:"users/error")
end

#This is the standard route 
get("/") do
    slim(:index)
end
#This is the login route
post("/login") do
    login_mail = params["login_mail"]
    login_password = params["login_password"]

    db = connect_to_db("db/db.db")

    result = get_info_from_mail(login_mail)

    if login_mail = nil
        set_error("Invalid login details")
        redirect("/users/error")
    end
    
    name = result["name"]
    user_id = result["id"]
    security = result["security_level"]
    password_digest = result["password"]
    if BCrypt::Password.new(password_digest) == login_password 
        session[:id] = user_id
        session[:name] = name
        session[:security] = security
        redirect("/home")
    else
        set_error("Invalid login details")
        redirect("/users/error")
    end
end
#This is the standard route when a user is logged in
get("/home") do 
    slim(:home)
end
#Here an admin can create new users
get("/users/create") do
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT * FROM users")
    slim(:"/users/create",locals:{users:result})
end
#This route is used to create new users
post("/users/create_user") do
    name = params[:name]
    password = params[:password]
    rank = params[:rank]
    security = params[:security]
    mail = params[:mail]
    db = connect_to_db("db/db.db")
    password_digest = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (name, password, rank, security_level, mail) VALUES (?,?,?,?,?)", name, password_digest, rank, security, mail)
    redirect("/users/create")
end
#This is used to delete users
post("/delete_user/:id/delete") do
    id = params[:id].to_i
    db = connect_to_db("db/db.db")
    result = db.execute("DELETE FROM users WHERE id = ?", id)
    redirect("/create")
end
#This route is used to create a new post
get("/post/new") do
    slim(:"/post/new")
end

post("/post/new_post") do
    title = params[:title]
    text = params[:text]
    genre = params[:genre]
    op = session[:name]
    db = connect_to_db("db/db.db")
    db.execute("INSERT INTO posts (title, text, genre, op) VALUES (?,?,?,?)", title, text, genre, op)
    redirect("/post/new")
end
#This is the route for the genre Gaming
get("/home/genres/gaming") do
    db = connect_to_db("db/db.db")
    gaming = "gaming"
    result = db.execute("SELECT * FROM posts WHERE genre = ?", gaming)

    if session[:security] <= 1
        slim(:"/genres/gaming",locals:{posts:result})
    else
        set_error("Too low security clearance")
        redirect("/users/error")
    end
end
#This route is used to delete posts
post("/delete_post/:id/delete") do
    id = params[:id].to_i
    db = connect_to_db("db/db.db")
    result = db.execute("DELETE FROM posts WHERE id = ?", id)
    redirect("/home")
end
#This route is used to update a post
post("/update_post/:id/update") do
    id = params[:id].to_i
    text = params["content"]
    db = connect_to_db("db/db.db")
    result = db.execute("UPDATE posts SET text = ? WHERE id = ?", text, id)
    redirect("/home")
end  
#This is the route for the genre Other
get("/home/genres/other") do
    db = connect_to_db("db/db.db")
    other = "other"
    result = db.execute("SELECT * FROM posts WHERE genre = ?", other)
    slim(:"/genres/other",locals:{posts:result})
end
#This route is used to logout
get("/logout") do
    session[:id] = nil
    redirect("/")
end