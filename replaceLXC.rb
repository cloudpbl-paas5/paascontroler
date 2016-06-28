require "./changeUserDB/DbOperation"
require "./changeUserDB/changeUserDB"

# get IP 
def getIP old_ip
  return old_ip if old_ip
  ip_pool = ["157.82.3.154", "157.82.3.155", "157.82.3.156", "157.82.3.157", "157.82.3.158", "157.82.3.159"]

  Lxc.select(:ip) do |lxc|
    ip_pool.delete lxc.ip
  end

  if ip_pool.size == 0
    p "Can not allocate IP"
    return "error"
  end

  ip_address = ip_pool.first
  p "new container with IP #{ip_address}"
  return ip_address
end



# First, you initilize DB connection.
DB_initialize()

user_name = ARGV[0]
repository_name = ARGV[1]

p "user name #{user_name} / repository name #{repository_name}"

#get LXC record from table Lxc 
userRepository = Usr_repo.find_by(usr_name: user_name, repo_name: repository_name)

old_ip = nil
#if it is first push
unless userRepository
  ip_address = getIP old_ip
  user_password = changeUserDB(repository_name, user_name, ip_address)  
  userRepository = Usr_repo.find_by(usr_name: user_name, repo_name: repository_name)
end
lxc = Lxc.find_by(repo_ID: userRepository.id)

if lxc != nil
  p "already have lxc with IP #{lxc.ip} and name : #{lxc.name}"
  old_ip = lxc.ip

  #kill old LXC  
  p "destroy old lxc container"
  system(`lxc-stop -n #{lxc.name}`)
  system(`lxc-destroy -n #{lxc.name}`)
  lxc.destroy 
end 

ip_address = getIP old_ip
#start new LXC

lxc_name = "#{user_name}-#{repository_name}-v#{Time.now.to_i.to_s}"
#system(`lxc-clone -o templete -n #{lxc_name}`)
system(`sudo lxc-create -t /home/yang/lxc/templates/staticpage-ubuntu -n #{lxc_name} -- --password="cloudpbl2016" --username=#{user_name} --dbpass=#{(p Usr_db.find_by(repo_id: userRepository.id)).passwd} --container_ip_address=#{ip_address} --db_ip_address="157.82.3.150" --reponame=#{repository_name}`)
#system(`echo "lxc.network.ipv4 = #{ip_address}" >> /var/lib/lxc/#{lxc_name}/config`) # redundant
system(`sudo lxc-start -n #{lxc_name} -d`)

lxc = Lxc.new(repo_id: userRepository.id, name: lxc_name, ip: ip_address)
lxc.save

p "set up lxc container"
system("ruby changeLoadBalancer.rb #{user_name} #{repository_name} #{ip_address}")
