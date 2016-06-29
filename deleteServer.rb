#! /usr/bin/env ruby
require 'tempfile'

def get_line_number(file, word)
  count = 0
  file = File.open(file, "r") { |file| file.each_line { |line|
    count += 1
    return count if line =~ /#{word}/
  }}
end
def remove_lines(filename, start, num)
  tmp = Tempfile.open("tmpfile") do |fp|
    File.foreach(filename) do |line|
      if $. >= start and num > 0
        num -= 1
      else
        fp.puts line
      end
    end
    fp
  end
  FileUtils.copy(tmp.path, filename)
  tmp.unlink
end

#delete server
$IP = ARGV[0]
file = '/etc/nginx/sites-enabled/www.paas2.exp.ci.i.u-tokyo.ac.jp'
if File.read(file).include?($IP) == true
    start = get_line_number(file, $IP)-1
    remove_lines(file, start, 11)
end    


#reload
system "sudo nginx -s reload"
