# frozen_string_literal: true

namespace :photos do
  desc "Download all provider and patient photos from URLs and store locally"
  task download_all: :environment do
    require "open-uri"
    require "fileutils"

    puts "Downloading provider and patient photos..."
    download_provider_photos
    download_patient_photos
    puts "✅ Photo download complete!"
  end

  private

  def download_provider_photos
    puts "\n📥 Downloading provider photos..."
    count = 0

    Provider.where.not(photo_url: nil).each do |provider|
      next unless provider.photo_url&.match?(%r{^https?://})

      filename = "#{provider.first_name.downcase}-#{provider.last_name.downcase}.jpg"
      local_path = download_photo(provider.photo_url, "providers", filename)

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

    Patient.where.not(photo_url: nil).each do |patient|
      next unless patient.photo_url&.match?(%r{^https?://})

      filename = "#{patient.first_name.downcase}-#{patient.last_name.downcase}.jpg"
      local_path = download_photo(patient.photo_url, "patients", filename)

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

  def download_photo(url, category, filename)
    dir = Rails.public_path.join("images", category)
    FileUtils.mkdir_p(dir)

    local_file = dir.join(filename)

    begin
      URI.open(url) do |remote_file|
        File.write(local_file, remote_file.read)
      end

      # Return the path relative to public root
      "/images/#{category}/#{filename}"
    rescue => e
      puts "    Error downloading #{url}: #{e.message}"
      nil
    end
  end
end
