# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

configure :development do
  activate :livereload
end

# Minify only for production
configure :build do
  activate :minify_css
  activate :minify_javascript
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

# Unpack seo directory contents into root level
ready do
  proxy "_redirects", "netlify_redirects", ignore: true
  sitemap.resources.select { |r| r.path =~ /^seo\// }.each do |r|
    proxy File.basename(r.path), r.path, ignore: false
  end
end

helpers do
  def markdown(text, without_p: false)
    @renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
    html = @renderer.render(text)

    if without_p
      # https://github.com/vmg/redcarpet/issues/92#issuecomment-35462000
      html = Regexp.new(/\A<p>(.*)<\/p>\Z/m).match(html)[1] rescue html
    end

    return html
  end

  def typographize(html)
    html = html.gsub('BWV', '<span class="acronym">BWV</span>')
    html.gsub!('H.', '<span class="acronym">H.</span>')
    html.gsub!('BBC', '<span class="acronym">BBC</span>')
    html.gsub!('REMA', '<span class="acronym">REMA</span>')
    html.gsub!('WDR', '<span class="acronym">WDR</span>')
    html.gsub!('VMII', '<span class="acronym">VMII</span>')
    html.gsub!('ARTE', '<span class="acronym">ARTE</span>')
    html.gsub!('U.S.', '<span class="acronym">U.S.</span>')

    html.gsub!('St ', 'St&nbsp;')
    html.gsub!('B ', 'B&nbsp;') # B minor mass
    html.gsub!('Sir John Eliot', 'Sir&nbsp;John&nbsp;Eliot')

    return html
  end
end
