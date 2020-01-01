require 'net/http'
require 'uri'
require 'json'

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

task pure_cloudflare_html_files do
  uri = URI(cloudflare_purge_cache_url(required_env_variable('CF_ZONE_ID')))
  payload =  {
      files:[
        "https://hugotunius.se/*.html",
        "https://hugotunius.se",
      ]
  }
  (api_key, api_email) = required_env_variables(['CF_API_KEY', 'CF_API_EMAIL'])
  headers = {
    'Authorization': "Bearer #{api_key}",
    'X-Auth-Email': api_email,
    'Content-Type': 'application/json',
  }

  response = Net::HTTP.post uri, payload.to_json, headers

  raise "Failed to purge cloudflare cache" if Net::HTTPResponse::CODE_TO_OBJ[response.code] != Net::HTTPOK
end

def jekyll(command)
  with_bundler "jekyll #{command}"
end

def with_bundler(command)
  sh "bundle exec #{command}"
end

def required_env_variable(name)
  required_env_variables([name])[0]
end

def required_env_variables(names)
  any_missing = names.any? { |name| ENV[name].nil? || ENV[name].empty? }
  raise "The #{names.map { |name| "`#{name}`" }.join(', ')} environment variable(s) are required" if any_missing

  names.map { |name| ENV[name] }
end

def cloudflare_purge_cache_url(zone_id)
  "https://api.cloudflare.com/client/v4/zones/#{zone_id}/purge_cache"
end
