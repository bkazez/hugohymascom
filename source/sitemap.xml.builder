regex = Regexp.compile(/(\.(css|js|eot|svg|woff|ttf|png|jpg|jpeg|gif|yml|mp3|zip|ics|keep|xml|ico|google)$|404|_redirects|robots|error|webmanifest)/)
xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  sitemap.resources.each do |resource|
  	next if resource.is_a?(Middleman::Sitemap::Extensions::RedirectResource)
    next if resource.url =~ regex
    next if resource.data.no_sitemap
    xml.url do
      xml.loc URI.join(data.site.host, resource.url)
      xml.lastmod Time.new.iso8601
    end
  end
end
