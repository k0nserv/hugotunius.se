task :default => :serve


desc 'Cleanup generated files'
task :clean do
  sh 'rm -rf _site'
end

desc 'Build the site'
task build: [:clean] do
  jekyll :build
end

desc 'Serve the site locally and watch for changes'
task serve: [:clean] do
  jekyll 'serve --drafts --incremental --watch'
end

def jekyll(command)
  with_bundler "jekyll #{command}"
end

def with_bundler(command)
  sh "bundle exec #{command}"
end
