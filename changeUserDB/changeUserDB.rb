#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

require 'mysql2'

usrname = ARGV[0]
ipaddr = ARGV[1]
passwd = ARGV[2]
repo_id = ARGV[3].to_i

client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "cloud2016", :database => "gitRepo")

# username, ipaddr, passwd, repo_id を引数にとり、ユーザー名からgitRipo.usr_repoを引く。
# 該当するrowがなければ初プッシュなので、ユーザーDBを作成。gitRepo.UserDBにその情報を書く。
results = client.query("SELECT * FROM gitRepo.Usr_repo WHERE usr_name = '#{usrname}'")
if results.count == 0 then
  client.query("CREATE USER '#{usrname}'@'#{ipaddr}' IDENTIFIED BY '#{passwd}'")
  client.query("CREATE DATABASE #{usrname}")
  client.query("GRANT ALL ON #{usrname}.* TO #{usrname}@#{ipaddr}")
  client.query("INSERT INTO gitRepo.Usr_db (repo_id, db_name, usr_name, passwd) VALUES (#{repo_id}, '#{usrname}', '#{usrname}', '#{passwd}')")
end
