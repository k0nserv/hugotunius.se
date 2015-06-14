#
# Jekyll Generator for SCSS
#
# (File paths in this description relative to jekyll project root directory)
# Place this file in ./_plugins
# Place .scss files in ./_scss
# Compiles .scss files in ./_scss to .css files in whatever directory you indicated in your config
# Config file placed in ./_sass/config.rb
#

require 'sass'
require 'pathname'
require 'compass'
require 'compass/exec'

module Jekyll

  class CompassGenerator < Generator
    safe true

    def generate(site)
      Dir.chdir File.expand_path('../_sass', File.dirname(__FILE__)) do
        Compass::Exec::SubCommandUI.new(%w(compile -c config.rb)).run!
      end
      Dir.chdir File.expand_path('../css', File.dirname(__FILE__)) do
        Dir.glob('*.css').each do |file|
          site.static_files << Jekyll::StaticFile.new(site, site.source, 'css', file)
        end
      end
    end

  end

end