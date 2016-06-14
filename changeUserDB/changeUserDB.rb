#!/usr/bin/ruby
# -*- encoding: utf-8 -*-
require "./DbOperation"

#client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "cloud2016", :database => "gitRepo")
DB_initialize()

# user1が新たに追加される例でのコード
results = Usr_repo.where(:usr_name => 'pst')
if results.count == 0 then
  







# results = client.query("SELECT * FROM gitRepo.UserRepositories WHERE userName = 'user1'")
# if results.count == 0 then
#   client.query("CREATE USER user1@157.82.3.150 IDENTIFIED BY 'password'")
#   client.query("CREATE DATABASE user1")
#   client.query("GRANT ALL ON user1.* TO user1@157.82.3.150")
#   client.query("INSERT INTO gitRepo.UserDB (repoID, dbName, userName, passwd) VALUES (1, 'user1', 'user1', 'password')")
# end
