#!/usr/bin/ruby
# -*- encoding: utf-8 -*-
require 'rubygems'
require 'active_record'

# テーブルにアクセスするためのクラスを宣言
class Lxc < ActiveRecord::Base
  self.table_name = 'Lxc'
end

class Usr_db < ActiveRecord::Base
  self.table_name = 'Usr_db'
end

class Usr_repo < ActiveRecord::Base
  self.table_name = 'Usr_repo'
end

def DB_initialize()
  ActiveRecord::Base.establish_connection(
    adapter:  "mysql2",
    host:     "localhost",
    username: "root",
    password: "cloud2016",
    database: "gitRepo",
  )
end
