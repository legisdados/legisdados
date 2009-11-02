#!/usr/bin/env ruby
require 'rubygems'
require 'fileutils'
require 'iconv'
require 'fastercsv'
require File.expand_path(File.join(File.dirname( __FILE__),
                                   'scraper_common'))


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
    @page_file_selector = File.join(@source_data_path, url_path(@base_url),
                                   'historic.asp*')
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
        page = File.read(Dir[@page_file_selector].first)
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

      Dir[@page_file_selector].each do |filepath|
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
