require 'icalendar'

module EventsHelpers
  MULTIVALUE_DELIMITER_REGEX = /\s*\|\s*/
  CATALOGUE_NAME_NUM_DELIMITER_REGEX = /\s*\/\s*/

  def all_events
    sorted_events(events_from_data(data.events) + events_from_data(data.events_remote)).reject(&:cancelled)
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
    array_wrap(e['rep']).first.split(MULTIVALUE_DELIMITER_REGEX).first
  end
end
