Gem::Specification.new do |spec|
  spec.name = "mapsqueak"
  spec.version = "0.0.2"
  spec.summary = "a REST client for MapSqueak"
  spec.files = Dir['lib/*.rb'] + Dir['bin/*.rb']
  spec.has_rdoc = true
  spec.bindir = 'bin'
  spec.author = "Ethan Stryker"
  spec.email = "e.stryker@gmail.com"
  spec.rubyforge_project = "mapsqueak"
  spec.description = <<-END
  A REST client for MapSqueak, a mobile enabled web app. 
  END
  spec.homepage = 'http://mapsqueak.rubyforge.org/'
end
