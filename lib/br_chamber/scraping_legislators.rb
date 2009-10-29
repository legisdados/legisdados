#!/usr/bin/env ruby
require 'rubygems'
require 'fileutils'
require 'iconv'
require 'fastercsv'
require 'optparse'

module ScrapingHelper

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

class LegislatorScraper
  include ScrapingHelper

  def initialize(opts={})
    @options = opts

    # Base directory where parsed data is going to be stored
    # TODO remove hardcoded legislature year range
    @data_path = File.expand_path(@options[:data_dir])

    # Directory to store the raw HTML pages we're scraping
    @source_data_path = File.expand_path(@options[:source_data_dir])

    # Pages come in iso-8859-1, we need utf-8
    @iconv = Iconv.new('UTF-8', 'iso-8859-1')

    # Regexes
    @num_entries = /Foram encontrados\s+(\d+)\s+/

    @base_url = "http://www.camara.gov.br/internet/deputado/historic.asp?" +
      "Pagina=%d&dt_inicial=01%%2F01%%2F1959&dt_final=31%%2F12%%2F2010&" +
      "parlamentar=&histMandato=1&ordenarPor=2&Submit3=Pesquisar"
    @base_source_path = File.join(@source_data_path, url_path(@base_url))
  end

  def run!
    get! unless @options[:noget]
    parse! unless @options[:noparse]
  end

  def get!
    num_pages = 0
    pages_left = 1
    page_number = 0

    while pages_left > 0 do
      page_number += 1
      url = @base_url % page_number
      puts "Downloading page #{page_number}..."

      Dir.chdir(@source_data_path) do
        `wget -x "#{url}"`
      end

      if page_number == 1
        page = File.read(Dir[File.join(@base_source_path, '*')].first)
        page =~ @num_entries

        num_entries = $1.to_i
        num_pages = num_entries / 30 + 1
        pages_left = num_pages
        puts "There is a total of #{num_pages} pages"
      end

      pages_left -= 1
    end
  end

  def parse!
    # Path where we store the final CSV file the legislator index
    path = File.join(@data_path, 'br', 'chamber', '2007-2010')
    legislator_index = File.join(path, 'legislator_index.csv')

    FileUtils.mkpath(path)

    page_number = 0

    field_names = ['chamber_id', 'nickname', 'state_code', 'party_code']

    FasterCSV.open(legislator_index, 'w', :headers => true) do |csv|
      csv << field_names

      Dir[File.join(@base_source_path, '*')].each do |filepath|
        page_number += 1
        puts "Parsing page #{page_number}..."

        page = File.read(filepath)
        legislators = page.map {|l|
          match = l =~ /id=(\d+)">(.*)<\/a> &nbsp;&nbsp; (\w+)\s+\/ (..)/
          match ? [$1, @iconv.iconv($2), $4, $3].map{|e| e.strip } : nil
        }.reject{|e| e.nil?}

        legislators.each do |legislator|
          csv << legislator
        end
      end
    end
  end
end

if __FILE__ == $0
  options = ScraperOptions.parse(ARGV)
  puts ARGV.inspect
  puts options.inspect
  f = LegislatorScraper.new(options)
  f.run!
end
