require 'uglifier'
require 'open-uri'
require 'fileutils'
require 'helpers/tenant_helpers.rb'

include TenantHelpers

TENANT_DIR = File.join('tenants', tenant) + '/'
TENANTS_GLOB = File.join('tenants', '*')

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

  # Unpack per-singer resources into the root level
  resources = sitemap.resources.select { |r| r.path.start_with?(TENANT_DIR) }
  resources.each do |r|
    proxy r.path.sub(TENANT_DIR, ''), r.path, ignore: true
  end
  ignore TENANTS_GLOB

  # Unpack seo directory contents into root level
  sitemap.resources.select { |r| r.path =~ /^seo\// }.each do |r|
    proxy File.basename(r.path), r.path, ignore: false
  end

  # Ignore pages that would be empty
  photos = File.join(root, 'source', ENV['TENANT'], 'images', 'photos')
  ignore 'photos.html' if !Dir.exist?(photos) || Dir.empty?(photos)
end

