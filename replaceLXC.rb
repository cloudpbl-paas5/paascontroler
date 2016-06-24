require "./changeUserDB/DbOperation"

# First, you initilize DB connection.
DB_initialize()

user_name = ARGV[0]
repository_name = ARGV[1]
p "user name #{user_name} / repository name #{repository_name}"
#get LXC record from table Lxc 
userRepository = Usr_repo.find_by(usr_name: user_name, repo_name: repository_name)
lxc = Lxc.find_by(repo_ID: userRepository.id)

old_ip = nil

if lxc != nil
  p "already have lxc with IP #{lxc.ip} and name : #{lxc.name}"
  old_ip = lxc.ip

  #kill old LXC  
  p "destroy old lxc container"
  system(`lxc-stop -n #{lxc.name}`)
  system(`lxc-destroy -n #{lxc.name}`)
  lxc.destroy 
end 

# get IP 
ip_pool = ["157.82.3.154", "157.82.3.155", "157.82.3.156", "157.82.3.157", "157.82.3.158", "157.82.3.159"]
unless old_ip
  Lxc.select(:ip) do |lxc|
    ip_pool.delete lxc.ip
  end
end

if ip_pool.size == 0
  p "Can not allocate IP"
end

ip_address = old_ip || ip_pool.first
p "new container with IP #{ip_address}"
#start new LXC
lxc_name = "#{user_name}-#{repository_name}-v#{Time.now.to_i.to_s}"
#system(`lxc-clone -o templete -n #{lxc_name}`)
system(`sudo lxc-create -t ubuntu -n #{lxc_name}`)
system(`echo "lxc.network.ipv4 = #{ip_address}" >> /var/lib/lxc/#{lxc_name}/config`)
system(`sudo lxc-start -n #{lxc_name} -d`)

lxc = Lxc.new(repo_id: userRepository.id, name: lxc_name, ip: ip_address)
lxc.save

p "set up lxc container"
system("ruby changeLoadBalancer.rb #{user_name} #{repository_name} #{ip_address}")
