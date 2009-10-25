#!/usr/bin/env ruby
require 'rubygems'
require 'fileutils'
require 'iconv'
require 'fastercsv'


# Base directory where data is going to be stored
DATA_PATH = File.join(Dir.pwd, 'data', 'br_chamber')

# Directory where we'll store the raw HTML pages we're scraping (for reference)
SOURCE_DATA_PATH = File.join(DATA_PATH, 'source_data', 'legislators', 'list')

# Path for each HTML page to be downloaded (page number to be interpolated)
LEGISLATORS_LIST = File.join(SOURCE_DATA_PATH, "page%0.2d.html")

# Path where we store the final CSV file with the scraped info
LEGISLATORS_CSV = File.join(DATA_PATH, 'legislators.csv')


iconv = Iconv.new('UTF-8', 'iso-8859-1')


# Regexen
NUM_ENTRIES = /Foram encontrados\s+(\d+)\s+/

base_url = "http://www.camara.gov.br/internet/deputado/historic.asp?" +
           "Pagina=%d&dt_inicial=01%%2F01%%2F1959&dt_final=31%%2F12%%2F2010&" +
           "parlamentar=&histMandato=1&ordenarPor=2&Submit3=Pesquisar"

# Make directories
FileUtils.mkpath(SOURCE_DATA_PATH)

num_pages = 0
pages_left = 1
page_number = 0

field_names = ['id', 'nickname', 'party_code', 'state_code']

FasterCSV.open(LEGISLATORS_CSV, 'w', :headers => true) do |csv|
  csv << field_names

  while pages_left > 0 do
    page_number += 1
    filepath = LEGISLATORS_LIST % page_number
    url = base_url % page_number
    puts "Downloading page #{page_number}..."
    `wget -O #{filepath} "#{url}"`

    page = File.read(filepath)
    legislators = page.map {|l|
      match = l =~ /id=(\d+)">(.*)<\/a> &nbsp;&nbsp; (\w+)\s+\/ (..)/
      match ? [$1, iconv.iconv($2), $3, $4].map{|e| e.strip } : nil
    }.reject{|e| e.nil?}

    legislators.each do |legislator|
      csv << legislator
    end

    if page_number == 1
      page =~ NUM_ENTRIES

      num_entries = $1.to_i
      num_pages = num_entries / 30 + 1
      pages_left = num_pages
      puts "There is a total of #{num_pages} pages"
    end

    pages_left -= 1
  end
end
