require 'mini_magick'
require 'fileutils'

module ImageHelpers
  # Generate responsive image with multiple sizes
  def responsive_image(source_path, alt_text, options = {})
    sizes = options[:sizes] || [320, 640, 1024, 1280, 1920]
    css_class = options[:class] || 'img-fluid'
    
    # Generate different sized images
    srcset_urls = sizes.map do |width|
      resized_path = resize_image(source_path, width)
      "#{resized_path} #{width}w"
    end.join(', ')
    
    # Use the largest size as the main src
    main_src = resize_image(source_path, sizes.last)
    
    # Auto-generate responsive_sizes if not provided
    responsive_sizes = options[:responsive_sizes] || generate_responsive_sizes(sizes)
    
    img_options = {
      src: main_src,
      srcset: srcset_urls,
      sizes: responsive_sizes,
      alt: alt_text,
      class: css_class,
      loading: 'lazy'
    }
    
    # Add style if provided
    img_options[:style] = options[:style] if options[:style]
    
    content_tag :img, '', img_options
  end
  
  # Generate picture element for art direction
  def picture_tag(source_path, alt_text, breakpoints = {})
    content = ''
    
    # Generate source elements for different breakpoints
    breakpoints.each do |media_query, width|
      resized_path = resize_image(source_path, width)
      content += content_tag :source, '', 
        srcset: resized_path,
        media: media_query
    end
    
    # Fallback img
    fallback_src = resize_image(source_path, 1024)
    content += content_tag :img, '', 
      src: fallback_src,
      alt: alt_text,
      class: 'img-fluid',
      loading: 'lazy'
    
    content_tag :picture do
      content.html_safe
    end
  end
  
  # Generate CSS for responsive background images
  def responsive_background_css(selector, source_path, breakpoints = {})
    css = ""
    
    # Default breakpoints if none provided
    if breakpoints.empty?
      breakpoints = {
        '(max-width: 768px)' => 768,
        '(max-width: 1024px)' => 1024,
        '(min-width: 1025px)' => 1920
      }
    end
    
    breakpoints.each do |media_query, width|
      resized_path = resize_image(source_path, width)
      css += "@media #{media_query} {\n"
      css += "  #{selector} {\n"
      css += "    background-image: url('#{resized_path}');\n"
      css += "  }\n"
      css += "}\n"
    end
    
    css
  end
  
  def resize_image(source_path, width)
    # Remove leading slash if present
    clean_path = source_path.sub(/^\//, '')
    
    # Parse the path
    file_parts = File.basename(clean_path, '.*')
    file_ext = File.extname(clean_path)
    dir_path = File.dirname(clean_path)
    
    # Create output filename in images_resized directory
    output_filename = "#{file_parts}_#{width}w#{file_ext}"
    output_path = "images_resized/#{dir_path == '.' ? output_filename : "#{dir_path}/#{output_filename}"}"
    
    # Full paths - source from source_dir, output to appropriate directory
    source_full_path = File.join(app.source_dir, clean_path)
    output_dir = app.development? ? app.source_dir : app.build_dir
    output_full_path = File.join(output_dir, output_path)
    
    # Check if source exists
    unless File.exist?(source_full_path)
      puts "⚠️  Image not found: #{source_full_path}"
      return source_path
    end
    
    # Only resize if output doesn't exist or is older
    if !File.exist?(output_full_path) || File.mtime(source_full_path) > File.mtime(output_full_path)
      puts "🖼️  Processing image: #{clean_path} → #{width}w"
      
      # Ensure output directory exists
      FileUtils.mkdir_p(File.dirname(output_full_path))
      
      # Resize image
      image = MiniMagick::Image.open(source_full_path)
      original_width = image.width
      
      # Only resize if image is larger than target width
      if original_width > width
        puts "   📏 Resizing from #{original_width}px to #{width}px"
        image.resize("#{width}>")
        image.write(output_full_path)
      else
        puts "   📋 Copying (original #{original_width}px ≤ target #{width}px)"
        FileUtils.cp(source_full_path, output_full_path)
      end
    else
      puts "✅ Using cached image: #{output_path}"
    end
    
    "/#{output_path}"
  end

  private

  # Generate responsive sizes string from sizes array
  def generate_responsive_sizes(sizes)
    return "100vw" if sizes.length <= 1
    
    # Sort sizes to ensure proper order
    sorted_sizes = sizes.sort
    
    # Generate media queries for all but the largest size
    media_queries = sorted_sizes[0..-2].map do |size|
      "(max-width: #{size}px) #{size}px"
    end
    
    # Add the largest size as the default (no media query)
    media_queries << "#{sorted_sizes.last}px"
    
    media_queries.join(", ")
  end
end