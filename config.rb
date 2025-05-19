require 'uglifier'
require 'open-uri'
require 'fileutils'
require 'yaml'

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

configure :development do
  activate :livereload
end

# Minify only for production
configure :build do
  activate :minify_css
  activate :minify_javascript, compressor: ::Uglifier.new(harmony: true)
  activate :minify_html
  activate :imageoptim, svgo: false
end

activate :directory_indexes
activate :meta_tags

# Netlify 404 page
page "/404.html", directory_index: false

# No layouts for these files
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
page '/*.ics', layout: false
page '/_redirects', layout: false

ready do
  proxy "_redirects", "netlify_redirects", ignore: true

  # Unpack seo directory contents into root level
  sitemap.resources.select { |r| r.path =~ /^seo\// }.each do |r|
    proxy File.basename(r.path), r.path, ignore: false
  end
end

