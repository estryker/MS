require 'rake/testtask'
require 'rake/rdoctask'

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_files.include("README","lib/*.rb")
  rd.options << "--all"
  rd.options << "--inline-source"
end

task :upload_docs => [:rdoc] do
 sh %(scp -r html/* e_stryker@mapsqueak.rubyforge.org:/var/www/gforge-projects/mapsqueak)
end

task :release => [:rdoc] do 
  sh %(gem build mapsqueak.gemspec)
  sh %(git push  gitosis@rubyforge.org:mapsqueak.git master)
  
# god I love ruby:
  newest_gem = Dir["mapsqueak-*.gem"].sort {|a,b| File.mtime(b) <=> File.mtime(a)}.first
  sh "gem push #{newest_gem}"
end
