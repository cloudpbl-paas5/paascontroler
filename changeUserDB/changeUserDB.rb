#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

require 'mysql2'

def changeUserDB(repo_name, user_name, ip_address)
  client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "cloud2016", :database => "gitRepo")
  # username, ipaddr, passwd, repo_id を引数にとり、ユーザー名からgitRipo.usr_repoを引く。
  # 該当するrowがなければ初プッシュなので、ユーザーDBを作成。gitRepo.UserDBにその情報を書く。
  client.query("INSERT INTO gitRepo.Usr_repo (usr_name, repo_name) VALUES ('#{user_name}', '#{repo_name}')")
  results = client.query("SELECT id FROM gitRepo.Usr_repo WHERE usr_name = '#{user_name}'")
  repo_id = 0
  results.each do |row|
    repo_id = row["id"]
  end
  passwd = [*0..9, *'a'..'z', *'A'..'Z'].sample(8).join
  client.query("CREATE USER '#{user_name}'@'#{ip_address}' IDENTIFIED BY '#{passwd}'")
  client.query("CREATE DATABASE #{user_name}")
  client.query("GRANT ALL ON #{user_name}.* TO #{user_name}@#{ip_address}")
  client.query("INSERT INTO gitRepo.Usr_db (repo_id, db_name, usr_name, passwd) VALUES (#{repo_id}, '#{user_name}', '#{user_name}', '#{passwd}')")
  return passwd
end
