require 'uglifier'
require 'open-uri'
require 'fileutils'
require 'yaml'
require 'models/event.rb'

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

  # Unpack seo directory contents into root level
  sitemap.resources.select { |r| r.path =~ /^seo\// }.each do |r|
    proxy File.basename(r.path), r.path, ignore: false
  end

  # Download calendar events from remote ICS
  ics_url = app.data.site.calendar_ics_url
  if !ics_url.empty?
    ics_path = File.join(app.root, 'data/calendar_remote.ics')
    if !File.exist?(ics_path)
      puts "Downloading ics from #{ics_url}"
      FileUtils.mkdir_p(File.dirname(ics_path))
      URI.open(ics_url) do |remote_file|
        File.write(ics_path, remote_file.read)
      end
    end

    events_remote_path = File.join(app.root, 'data/events_remote.yml')
    File.open(ics_path) do |cal_file|
      cals = Icalendar::Calendar.parse(cal_file)
      if cals.length == 0
        puts "No calendar events in downloaded file."
      else
        events_array = cals.first.events.map do |ics_event|
          dtstart = ics_event.dtstart&.value # can be either a Date or a Icalendar::Values::Helpers::ActiveSupportTimeWithZoneAdapter
          if dtstart&.respond_to?(:time)
            dtstart = dtstart.time
          end

          event_hash = {}
          event_hash['date'] = dtstart.to_date
          event_hash['title'] = ics_event.summary&.value
          event_hash['venue'] = ics_event.location&.value
          event_hash['description'] = ics_event.description&.value

          event_hash
        end
      end
      puts File.write(events_remote_path, events_array.to_yaml)
    end
  end
end

