#!/usr/bin/ruby

require 'open3' # see https://kaihar4.com/2015/01/18/ruby-shell.html

paasUserName = ARGV[0]  # tomoya, yang, chen. Ruby does not store command name 'createRepositoryOf.rb' in ARGV
paasRepoName = ARGV[1]

unless paasRepoName
  puts "usage:  ./#{$0} <userName> <repoName>"
  exit 1
end

gitoliteAdminDirPath = '/home/gitadmin/gitolite-admin/'
   targetTmpFilePath = gitoliteAdminDirPath + 'newRepo.tmp'
gitoliteConfFilePath = gitoliteAdminDirPath + 'conf/gitolite.conf'

# capture3 returns arrays of stdout, stderr, status

# the 'cat' command does not handle stdin well, so I use a tmp file.

File.write( targetTmpFilePath,
"""
repo    #{paasUserName}/#{paasRepoName}
        RW+     =   gitadmin
        RW      =   #{paasUserName}
        R       =   gitreadonly
""")


out, err, status = Open3.capture3("cat #{targetTmpFilePath} >> #{gitoliteConfFilePath} ")
puts out
puts err
puts status
puts "The following configuration is added in #{gitoliteConfFilePath} \n" + Open3.capture3("cat #{targetTmpFilePath}")[0] + "\n"

out, err, status = Open3.capture3("rm #{targetTmpFilePath}")
puts out
puts err
puts status


out, err, status = Open3.capture3("cd #{gitoliteAdminDirPath} && git commit -m 'add #{paasUserName}/#{paasRepoName} by #{$0}' #{gitoliteConfFilePath} && git push")
puts out
puts err
puts status


def rewriteHookScript(userName, repoName)

targetHookFilePath = "/home/git/repositories/#{userName}/#{repoName}.git/hooks/post-update"
replaceLXCPath = "/home/gitadmin/misc/replaceLXC.rb"

File.write( targetHookFilePath,
"""
#!/usr/bin/sh

ruby #{replaceLXCPath}

""")

puts "written in #{targetHookFilePath}"

end

#rewriteHookScript paasUserName, paasRepoName
