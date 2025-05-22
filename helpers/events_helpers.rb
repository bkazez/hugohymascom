require 'icalendar'

class Event
  def initialize(hash)
    @data = hash
    hash.each_key do |key|
      define_singleton_method(key) { @data[key] }
    end
  end

  def method_missing(name, *args, &block)
    nil
  end

  def respond_to_missing?(name, include_private = false)
    true
  end
end

module EventsHelpers
  MULTIVALUE_DELIMITER_REGEX = /\s*\|\s*/
  CATALOGUE_NAME_NUM_DELIMITER_REGEX = /\s*\/\s*/

  def all_events
    processed_events = process_copy_from_events(tenant_data.events)
    sorted_events(events_from_data(processed_events) + events_from_data(events_remote)).reject(&:cancelled)
  end

  def events_remote
    return @events_remote if defined?(@events_remote)

    begin
      ics_url = tenant_data.site.calendar_ics_url
      ics_content = URI.open(ics_url).read
      cals = Icalendar::Calendar.parse(ics_content)

      if cals.empty?
        puts "No calendar events in downloaded file."
        @events_remote = []
      else
        @events_remote = cals.first.events.map do |ics_event|
          dtstart = ics_event.dtstart&.value
          dtstart = dtstart.time if dtstart&.respond_to?(:time)
          
          Event.new({
            date: dtstart.to_date,
            title: ics_event.summary&.value,
            venue: ics_event.location&.value,
            description: ics_event.description&.value
          })
        end
      end
    rescue => e
      puts "Event fetch failed: #{e.class} - #{e.message}"
    end

    return @events_remote
  end

  def events_from_data(events_arr)
    events_arr.map do |e|
      if e.title.nil?
        e.title = first_rep(e)
      end
      e
    end
  end

  def future_events()
    all_events().select { |e| first_event_date(e) >= Date.today }
  end

  def past_events(only_fancy: true)
    all_events.select do |e|
      first_event_date(e) < Date.today && (!only_fancy || e.fancy)
    end
  end

  def sorted_events(events)
    events.sort_by { |e| first_event_date(e) }
  end

  def first_event_date(event)
    array_wrap(event.date).first
  end

  def event_image_path(event)
    if event.image.present?
      '/images/events/' + event.image
    else
      '/images/events/' + first_event_date(event).strftime('%Y-%m-%d') + '.jpg'
    end
  end

  def parse_rep(text, html: true)
    work, role = text.split(MULTIVALUE_DELIMITER_REGEX)

    # Replace opening straight quotes with opening curly quotes
    work.gsub!(/\b'/, "‘")
    # Replace closing straight quotes with closing curly quotes
    work.gsub!(/'\b/, "’")

    if html
      str = work.gsub(/_([^_]+)_/, '<em>\1</em>')
    else
      str = work.gsub(/_([^_]+)_/, '\1')
    end

    str += " — #{role}" if role.present?
    return str
  end

  def parse_leader(text)
    str, role = text.split(MULTIVALUE_DELIMITER_REGEX)
    str += ", #{role}" if role.present?
    return str
  end

  def array_wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end

  def first_rep(e)
    array_wrap(e['rep']).first&.split(MULTIVALUE_DELIMITER_REGEX)&.first
  end

  # Process events with copy_from functionality
  # Events can reference previous events by date to copy all fields,
  # then override specific fields as needed
  def process_copy_from_events(events)
    return [] if events.nil?
    
    # Ensure we have an array to work with
    events_array = events.is_a?(Array) ? events : []
    
    # Track events by date for copy_from lookup
    # Only allows copying from events that appear earlier in the list
    events_by_date = {}
    processed_events = []
    
    # Process events in order
    events_array.each do |event|
      processed_event_data = nil
      
      if event['copy_from']
        # This event wants to copy from a previous event
        source_event = events_by_date[event['copy_from']]
        
        if source_event
          # Copy all fields from source event
          merged_event = source_event.dup
          
          # Override with any fields specified in this event
          event.each do |key, value|
            next if key == 'copy_from'  # Don't copy the copy_from field itself
            merged_event[key] = value
          end
          
          processed_event_data = merged_event
          processed_events << Event.new(merged_event)
        else
          # Source event not found - warn and use event as-is
          puts "Warning: copy_from date '#{event['copy_from']}' not found for event on #{event['date']}"
          processed_event_data = event
          processed_events << Event.new(event)
        end
      else
        # Regular event
        processed_event_data = event
        processed_events << Event.new(event)
      end
      
      # Add processed event to lookup table for future copy_from references
      # (only if it has a date)
      if processed_event_data && processed_event_data['date']
        events_by_date[processed_event_data['date']] = processed_event_data
      end
    end
    
    processed_events
  end
end
