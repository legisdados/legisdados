#!/usr/bin/env ruby
require 'rubygems'
require 'fileutils'
require 'iconv'
require 'fastercsv'
require 'optparse'

class ScraperOptions

  def self.parse(args)
    script_name = File.basename($0)
    options = {}

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{script_name}"

      opts.on(:REQUIRED, '-dDIR', '--directory=DIR', 'Output directory for ' +
              'data (optional, defaults to current dir)') do |dir|
        options[:output_directory] = dir
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

    options[:output_directory] ||= Dir.pwd

    options
  end
end

class LegislatorScraper

  def initialize(opts={})
    @options = opts

    # Base directory where data is going to be stored
    @basedir = File.expand_path(@options[:output_directory])
    puts @basedir
    @data_path = File.join(@basedir, 'br_chamber')

    # Directory to store the raw HTML pages we're scraping
    @source_data_path = File.join(@data_path, 'source_data', 'legislators',
                                  'list')
    # Path for each HTML page to be downloaded (page number to be interpolated)
    @legislators_list = File.join(@source_data_path, "page%0.2d.html")

    # Path where we store the final CSV file with the scraped info
    @legislators_csv = File.join(@data_path, 'legislators.csv')

    # Pages come in iso-8859-1, we need utf-8
    @iconv = Iconv.new('UTF-8', 'iso-8859-1')

    # Regexes
    @num_entries = /Foram encontrados\s+(\d+)\s+/

    @base_url = "http://www.camara.gov.br/internet/deputado/historic.asp?" +
      "Pagina=%d&dt_inicial=01%%2F01%%2F1959&dt_final=31%%2F12%%2F2010&" +
      "parlamentar=&histMandato=1&ordenarPor=2&Submit3=Pesquisar"
  end

  def run!
    get! unless @options[:noget]
    parse! unless @options[:noparse]
  end

  def get!
    # Make directories
    FileUtils.mkpath(@source_data_path)

    num_pages = 0
    pages_left = 1
    page_number = 0

    while pages_left > 0 do
      page_number += 1
      filepath = @legislators_list % page_number
      url = @base_url % page_number
      puts "Downloading page #{page_number}..."
      `wget -O #{filepath} "#{url}"`

      if page_number == 1
        page = File.read(filepath)
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
    num_pages = Dir.chdir(@source_data_path) { Dir['*.html'] }.size
    pages_left = num_pages
    page_number = 0

    field_names = ['id', 'nickname', 'state_code', 'party_code']

    FasterCSV.open(@legislators_csv, 'w', :headers => true) do |csv|
      csv << field_names

      while pages_left > 0 do
        page_number += 1
        filepath = @legislators_list % page_number
        puts "Parsing page #{page_number}..."

        page = File.read(filepath)
        legislators = page.map {|l|
          match = l =~ /id=(\d+)">(.*)<\/a> &nbsp;&nbsp; (\w+)\s+\/ (..)/
          match ? [$1, @iconv.iconv($2), $4, $3].map{|e| e.strip } : nil
        }.reject{|e| e.nil?}

        legislators.each do |legislator|
          csv << legislator
        end

        pages_left -= 1
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
