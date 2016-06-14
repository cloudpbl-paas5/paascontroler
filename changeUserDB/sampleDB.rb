#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

#require DbOperation.rb
require "./DbOperation"

# First, you initilize DB connection.
DB_initialize()

# You can use Lxc, Usr_db, Usr_repo.
p Lxc.all
p Usr_db.all
p Usr_repo.all
