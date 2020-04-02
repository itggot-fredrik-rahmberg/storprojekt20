require'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'

require_relative 'models/get_info_from_user.rb'
require_relative 'models/info_posts.rb'
require_relative 'models/BCrypt.rb'

load 'db_functions.rb'

enable :sessions

# Att göra Upvote för n-n. Cascade (ta bort user). Dok. MVC, REST-a resurser. 

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
#This route is shown when an error message occurs
get("/users/error") do
    slim(:"users/error")
end

#This is the standard route  when entering the website
get("/") do
    slim(:index)
end
#This is the login route
post("/login") do

    if session[:now]
        time = session[:now].split("_")
        if Time.new(time[0], time[1], time[2], time[3], time[4], time[5]) > (Time.now - 300)
            set_error("You have to wait 5 minutes until you try again")
            redirect("/users/error")
        end
    end

    login_mail = params["login_mail"]
    login_password = params["login_password"]

    result = get_info_from_mail(login_mail)

    if login_mail == nil
        set_error("Invalid login details")
        redirect("/users/error")
    end

    attempts = session[:attempts] 
    if attempts == nil
        attempts = 0
    end

    name = result["name"]
    user_id = result["id"]
    security = result["security_level"]
    password_digest = result["password"]
    if login(password_digest) == login_password 
        session[:id] = user_id
        session[:name] = name
        session[:security] = security
        redirect("/home")
    else
        set_error("Invalid login details")
        attempts += 1
        session[:attempts] = attempts

        if attempts >= 3
            session[:now] = Time.now().strftime('%Y_%m_%d_%H_%M_%S')
        end

        redirect("/users/error")
    end
end
#This is the standard route when a user is logged in
get("/home") do 
    slim(:home)
end
#Here an admin can create new users
get("/users/create") do

    if session[:security] == 0
        result = get_all_info_from_user()
        slim(:"/users/create",locals:{users:result})
    else
        set_error("You couldn't enter this site because you're not an admin")
        redirect("/users/error")
    end

end
#This route is used to create new users
post("/users/create_user") do
    name = params[:name]
    password = params[:password]
    rank = params[:rank]
    security = params[:security]
    mail = params[:mail]
    password_digest = digest(password)

    create_user(name, password_digest, rank, security, mail)

    redirect("/users/create")
end
#This is used to delete users
post("/delete_user/:id/delete") do
    id = params[:id].to_i
    delete_user(id)
    redirect("/users/create")
end
#This route is used to create a new post
get("/post/new") do
    slim(:"/post/new")
end

post("/post/new_post") do
    title = params[:title]
    text = params[:text]
    genre = params[:genre]
    id = session[:id]

    create_post(title, text, genre, id)

    redirect("/post/new")
end
#This is the route for the genre Gaming
get("/home/genres/gaming") do
    gaming = "gaming"
    result = enter_genre(gaming)

    if session[:security] <= 1
        slim(:"/genres/gaming",locals:{posts:result})
    else
        set_error("Too low security clearance to enter this genre")
        redirect("/users/error")
    end
end

post("/upvote") do
    user_id = session[:id]
    post_id = params["post_id"]
    upvote(user_id, post_id)

    redirect("/home")
end


#This route is used to delete posts
post("/delete_post/:id/delete") do
    id = params[:id].to_i
    result = delete_post(id)
    redirect("/home")
end
#This route is used to update a post
post("/update_post/:id/update") do
    id = params[:id].to_i
    text = params["content"]
    result = update_post(text, id)
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