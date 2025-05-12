module TypographyHelpers
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
    html.gsub!('Ben Kazez', 'Ben&nbsp;Kazez')

    return html
  end
end