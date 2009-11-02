# -*- coding: utf-8 -*-
require 'optparse'
require 'unicode'

module ScrapingHelper
  include Unicode

  # takes utf8 strings
  def strip_diacritics(utf8_string)
    # separate the character and the diacritic, e.g. "á" -> "a'"
    formD = normalize_D(utf8_string)
    # remove the separated diacritics (by keeping only ASCII letters and space)
    formD.tr('^a-zA-Z ', '')
  end

  # Expects a full URL, beginning with 'http://'
  def url_path(url)
    path = url[7..-1] # remove 'http://'
    path.split('/')[0...-1].join('/')
  end

end

class ScraperOptions

  def self.parse(args)
    script_name = File.basename($0)
    options = {}

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{script_name}"

      opts.on(:REQUIRED, '-dDIR', '--data=DIR', 'Output directory for ' +
              'parsed data (optional, defaults to ./data)') do |dir|
        options[:data_dir] = dir
      end

      opts.on(:REQUIRED, '-sDIR', '--source-data=DIR', 'Output directory ' +
              'for raw data (optional, defaults to ./source_data)') do |dir|
        options[:source_data_dir] = dir
      end

      opts.on(:NONE, '--no-parse', "Only download pages to be scraped, " +
              "but don't parse them") do |dir|
        options[:noparse] = true
      end

      opts.on(:NONE, '--no-get',
              'Parse pages without downloading them.') do |dir|
        options[:noget] = true
      end
    end

    begin
      opts.parse!(args)
    rescue => e
      puts e.message.capitalize + "\n\n"
      puts opts
      exit 1
    end

    options[:data_dir] ||= File.join(Dir.pwd, 'data')
    options[:source_data_dir] ||= File.join(Dir.pwd, 'source_data')

    options
  end
end
