#! /usr/bin/env ruby


#write new server to nginx
$username = ARGV[0]
$reponame = ARGV[1]
$IP = ARGV[2]
$IPtodelete = ARGV[3]
#1.add new lxc
file = '/etc/nginx/sites-enabled/www.paas2.exp.ci.i.u-tokyo.ac.jp'
if File.read(file).include?($IP) == false
    line = File.open(file,"a") do|line|
    line.puts "\n" + "upstream #$username-#$reponame {"
    line.puts "        server #$IP;"+"\n"+"}"+
"server {"+"\n"+"        listen 80;"+"\n"+"        server_name #$username-#$reponame.www.paas.exp.ci.i.u-tokyo.ac.jp;"+"\n"+"        location / {"+"\n"+"                proxy_pass  http://#$username-#$reponame;"+"\n"+"                include /etc/nginx/proxy_params;"+"\n"+"        }"+"\n"+"}"
    end
end    

#reload
system "sudo nginx -s reload"
