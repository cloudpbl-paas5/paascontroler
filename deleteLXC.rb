require "./changeUserDB/DbOperation"
require "./changeUserDB/changeUserDB"

DB_initialize()

user_name = ARGV[0]
repository_name = ARGV[1]

userRepository = Usr_repo.find_by(usr_name: user_name, repo_name: repository_name)

lxc = Lxc.find_by(repo_ID: userRepository.id)

if lxc != nil
  p "delete lxc with IP #{lxc.ip} and name : #{lxc.name}"

  #kill old LXC  
  p "stop old lxc container"
  system(`lxc-stop -n #{lxc.name}`)
  p "destroy old lxc container"
  system(`lxc-destroy -n #{lxc.name}`)
  lxc.destroy
end

system("ruby deleteServer.rb #{lxc.ip}")
