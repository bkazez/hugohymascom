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

activate :i18n do |options|
  options.no_fallbacks = true
end

activate :directory_indexes
activate :meta_tags

activate :imageoptim do |options|
  # Use a build manifest to prevent re-compressing images between builds
  options.manifest = true

  # Silence problematic image_optim workers
  options.skip_missing_workers = true

  # Cause image_optim to be in shouty-mode
  options.verbose = true

  # Setting these to true or nil will let options determine them (recommended)
  options.nice = true
  options.threads = true

  # Image extensions to attempt to compress - PNGs slowed down the build
  options.image_extensions = %w(.jpg)

  # Compressor worker options, individual optimisers can be disabled by passing
  # false instead of a hash
  options.advpng    = { :level => 4 }
  options.gifsicle  = { :interlace => false }
  options.jpegoptim = { :strip => ['all'], :allow_lossy => true, :max_quality => 80 }
  options.jpegtran  = { :copy_chunks => false, :progressive => true, :jpegrescan => true }
  options.optipng   = { :level => 6, :interlace => false }
  options.pngcrush  = { :chunks => ['alla'], :fix => false, :brute => false }
  options.pngout    = { :copy_chunks => false, :strategy => 0 }
  options.svgo      = false
end

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
    html.gsub!('Hugo Hymas', 'Ben&nbsp;Kazez')

    return html
  end
end
