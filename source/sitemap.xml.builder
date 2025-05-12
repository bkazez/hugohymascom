xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  sitemap.resources.each do |resource|
  	# Skip redirects
  	puts resource.inspect
  	next if resource.is_a?(Middleman::Sitemap::Extensions::RedirectResource)
    xml.url do
      xml.loc URI.join(data.site.host, resource.url)
      xml.lastmod Time.new.iso8601
    end if resource.url !~ Regexp.compile(data.site.sitemap_ignore_regex)
  end
end
