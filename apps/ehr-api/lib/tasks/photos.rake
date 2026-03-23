# frozen_string_literal: true

namespace :photos do
  desc 'Download all provider and patient photos from URLs and store locally'
  task download_all: :environment do
    require 'open-uri'
    require 'fileutils'

    puts 'Downloading provider and patient photos...'
    download_provider_photos
    download_patient_photos
    puts '✅ Photo download complete!'
  end

  desc 'Download photos from House fandom wiki character pages'
  task download_from_fandom: :environment do
    require 'open-uri'
    require 'fileutils'
    require 'nokogiri'

    puts 'Downloading photos from House fandom wiki...'
    download_fandom_provider_photos
    download_fandom_patient_photos
    puts '✅ Fandom photo download complete!'
  end

  private

  def download_provider_photos
    puts "\n📥 Downloading provider photos..."
    count = 0

    Provider.where.not(photo_url: nil).find_each do |provider|
      next unless provider.photo_url&.match?(%r{^https?://})

      filename = "#{provider.first_name.downcase}-#{provider.last_name.downcase}.jpg"
      local_path = download_photo(provider.photo_url, 'providers', filename)

      if local_path
        provider.update!(photo_url: local_path)
        count += 1
        puts "  ✓ #{provider.full_name}"
      else
        puts "  ✗ #{provider.full_name} (failed to download)"
      end
    end

    puts "Downloaded #{count} provider photos"
  end

  def download_patient_photos
    puts "\n📥 Downloading patient photos..."
    count = 0

    Patient.where.not(photo_url: nil).find_each do |patient|
      next unless patient.photo_url&.match?(%r{^https?://})

      filename = "#{patient.first_name.downcase}-#{patient.last_name.downcase}.jpg"
      local_path = download_photo(patient.photo_url, 'patients', filename)

      if local_path
        patient.update!(photo_url: local_path)
        count += 1
        puts "  ✓ #{patient.full_name}"
      else
        puts "  ✗ #{patient.full_name} (failed to download)"
      end
    end

    puts "Downloaded #{count} patient photos"
  end

  def download_fandom_provider_photos
    puts "\n📥 Downloading provider photos from Fandom..."
    count = 0

    Provider.where.not(photo_url: nil).find_each do |provider|
      next unless provider.photo_url&.include?('house.fandom.com')

      image_url = extract_fandom_image(provider.photo_url)
      next unless image_url

      filename = "#{provider.first_name.downcase}-#{provider.last_name.downcase}.jpg"
      local_path = download_photo(image_url, 'providers', filename)

      if local_path
        provider.update!(photo_url: local_path)
        count += 1
        puts "  ✓ #{provider.full_name}"
      else
        puts "  ✗ #{provider.full_name} (failed to download)"
      end
    end

    puts "Downloaded #{count} provider photos from Fandom"
  end

  def download_fandom_patient_photos
    puts "\n📥 Downloading patient photos from Fandom..."
    count = 0

    Patient.where.not(photo_url: nil).find_each do |patient|
      next unless patient.photo_url&.include?('house.fandom.com')

      image_url = extract_fandom_image(patient.photo_url)
      next unless image_url

      filename = "#{patient.first_name.downcase}-#{patient.last_name.downcase}.jpg"
      local_path = download_photo(image_url, 'patients', filename)

      if local_path
        patient.update!(photo_url: local_path)
        count += 1
        puts "  ✓ #{patient.full_name}"
      else
        puts "  ✗ #{patient.full_name} (failed to download)"
      end
    end

    puts "Downloaded #{count} patient photos from Fandom"
  end

  def extract_fandom_image(fandom_url)
    return nil unless fandom_url&.include?('house.fandom.com')

    begin
      # Fetch the Fandom page
      response = URI.open(fandom_url, 'User-Agent' => 'Mozilla/5.0').read
      doc = Nokogiri::HTML(response)

      # Try to find infobox image (character portrait)
      infobox_image = doc.css("img[alt*='Infobox']").first ||
                      doc.css('.pi-image img').first ||
                      doc.css('.character-image img').first ||
                      doc.css('figure img').first

      return infobox_image['src'] if infobox_image

      # Fallback: find the first meaningful image in the page
      page_image = doc.css('img').find do |img|
        src = img['src']
        src&.include?('fandom.com/') && src.exclude?('wiki/') &&
          src.match?(/\.(jpg|jpeg|png|gif)/i)
      end

      page_image ? page_image['src'] : nil
    rescue StandardError => e
      puts "    Error extracting image from #{fandom_url}: #{e.message}"
      nil
    end
  end

  def download_photo(url, category, filename)
    return nil if url.blank?

    # Make relative URLs absolute
    url = "https:#{url}" if url.start_with?('//')

    dir = Rails.public_path.join('images', category)
    FileUtils.mkdir_p(dir)

    local_file = dir.join(filename)

    begin
      URI.open(url, 'User-Agent' => 'Mozilla/5.0') do |remote_file|
        File.write(local_file, remote_file.read)
      end

      # Return the path relative to public root
      "/images/#{category}/#{filename}"
    rescue StandardError => e
      puts "    Error downloading #{url}: #{e.message}"
      nil
    end
  end
end
