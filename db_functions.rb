
#This functions makes it so I don't have to repeat myself in module with these two lines of code
def connect_to_db(path) 
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end 