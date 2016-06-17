require "./changeUserDB/DbOperation"

# First, you initilize DB connection.
DB_initialize()

user_name = ARGV[0]
repository_name = ARGV[1]

#get LXC record from table Lxc 
userRepository = Usr_repo.find_by(user_name: user_name, repository_name: repository_name)
lxc = Lxc.find_by(repo_ID: userRepository.id)

old_ip = nil

if lxc != nil
  old_ip = lxc.ip

  #kill old LXC  
  system(`lxc-stop -n #{lxc.name}`)
  system(`lxc-destory -n #{lxc.name}`)
  lxc.destory 
end 

# get IP 
ip_pool = ["157.82.3.154", "157.82.3.155", "157.82.3.156", "157.82.3.157", "157.82.3.158", "157.82.3.159"]
unless old_ip
  lxc.select(:ip) do |lxc|
    ip_pool.delete lxc.id
  end
end

if ip_pool.size == 0
  p "Can not allocate IP"
end

ip_address = old_ip || ip_pool.first
#start new LXC
lxc_name = "#{user_name}-#{repository_name}-v#{Time.now.to_i.to_s}"
system(`lxc-clone -o template -n #{lxc_name}`)
system(`echo "lxc.network.ipv4 = #{ip_address}" >> /var/lib/lxc/#{lxc_name}/config`)
system(`sudo lxc-start -n #{lxc_name} -d`)

#TODO user-DB  LXC(new) 起動（最中に、user-DBのmigration（スキーマの更新）を行う）

lxc = Lxc.new(repo_ID: userRepository.id, name: "#{user_name}-#{repository_name}-#{Time.now.to_i.to_s}", ip: ip_address)
lxc.save
ruby changeLoadBalancer.rb username, reponame, IP
