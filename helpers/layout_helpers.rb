module LayoutHelpers
  def current_hero_image_path
    current_url = current_page.url.chomp('/')
    current_nav_item = data.site.nav.find { |item| item.path.chomp('/') == current_url }
    return current_nav_item&.hero_image_path
  end
end
