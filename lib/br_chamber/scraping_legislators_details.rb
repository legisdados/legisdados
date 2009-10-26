#!/usr/bin/env ruby
require 'rubygems'
require 'iconv'
require 'fileutils'
require 'cgi'
require 'fastercsv'
require 'scraping_legislators' # ScraperOptions

class LegislatorDetailsScraper

  def initialize(opts={})
    @options = opts

    # Base directory where data is going to be stored
    @basedir = File.expand_path(@options[:output_directory])
    puts @basedir
    @data_path = File.join(@basedir, 'br_chamber')

    # Directory to store the raw HTML bio pages
    @bios_source_path = File.join(@data_path, 'source_data', 'legislators',
                                  'bios')

    # Directory to store the raw HTML bio pages
    @details_source_path = File.join(@data_path, 'source_data', 'legislators',
                                     'details')

    # Path for the CSV where we get the legislator names and IDs
    @legislators_csv = File.join(@data_path, 'legislators.csv')

    # Detail pages come in iso-8859-1, we need utf-8
    @iconv = Iconv.new('UTF-8', 'iso-8859-1')

    # Regexes
    @regexes = {
      :picture => Regexp.new('^<img src=\"(\/internet\/deputado\/fotos\/' +
                             '[^.]*.jpg)".*alt=\"Foto do Deputado.*' + "$"),
      :full_name => /^<td>Nome Civil: (.*)$/,
      :full_name_line_feed => /^<td>Nome Civil: (.*)<[bB][rR]>$/,
      :subscription_number => Regexp.new('^<A HREF="RelVotacoes.asp[?]' +
                                         'nuLegislatura=\d+&' +
                                         'nuMatricula=(\d+).*' + "$"),
      :end_of_line => /^(.*)<[bB][rR]>$/
    }

    @bio_base_url = "http://www2.camara.gov.br/internet/deputados/" +
      "biodeputado/index.html?nome=%s&leg=53"

    @detail_base_url = "http://www.camara.gov.br/internet/deputado/" +
      "Dep_Detalhe.asp?id=%d"
  end

  def url_escape(string)
    iconv = Iconv.new('iso-8859-1', 'utf-8')
    CGI.escape(iconv.iconv(string))
  end

  def run!
    get! unless @options[:noget]
    parse! unless @options[:noparse]
  end

  def get!
    # Make directories
    FileUtils.mkpath(@bios_source_path)
    FileUtils.mkpath(@details_source_path)

    FasterCSV.foreach(@legislators_csv, :headers => true) do |row|
      bio_filepath = File.join(@bios_source_path, "#{row['id']}.html")
      bio_url = @bio_base_url % url_escape(row['nickname'])
      puts "Downloading bio for #{row['nickname']} (id=#{row['id']})..."
      `wget -O #{bio_filepath} "#{bio_url}"`


      detail_filepath = File.join(@details_source_path, "#{row['id']}.html")
      detail_url = @detail_base_url % row['id']
      puts "Downloading details for #{row['nickname']} (id=#{row['id']})..."
      `wget -O #{detail_filepath} "#{detail_url}"`
    end
  end

  def parse!
    #   # Make directories
    #   FileUtils.mkpath(@data_path)

    #   num_pages = Dir.chdir(@source_data_path) { Dir['*.html'] }.size
    #   pages_left = num_pages
    #   page_number = 0

    #   field_names = ['id', 'nickname', 'state_code', 'party_code']

    #   FasterCSV.open(@legislators_csv, 'w', :headers => true) do |csv|
    #     csv << field_names

    #     while pages_left > 0 do
    #       page_number += 1
    #       filepath = @legislators_list % page_number
    #       puts "Parsing page #{page_number}..."

    #       page = File.read(filepath)
    #       legislators = page.map {|l|
    #         match = l =~ /id=(\d+)">(.*)<\/a> &nbsp;&nbsp; (\w+)\s+\/ (..)/
    #         match ? [$1, @iconv.iconv($2), $4, $3].map{|e| e.strip } : nil
    #       }.reject{|e| e.nil?}

    #       legislators.each do |legislator|
    #         csv << legislator
    #       end

    #       pages_left -= 1
    #     end

    #   end
  end
end

if __FILE__ == $0
  options = ScraperOptions.parse(ARGV)
  puts ARGV.inspect
  puts options.inspect
  f = LegislatorDetailsScraper.new(options)
  f.run!
end

# legislators = []


# # Updates profile info for each legislator
# FasterCSV.foreach(LEGISLATORS_CSV, :headers => true) do |row|
#   puts row['nickname']
#   path = File.join(DATA_PATH, '/source_data/legislators/details')
#   FileUtils.mkpath(path)
#   filepath = File.join(path, row['chamber_id'] + '.html')
#   detail_url = 'http://www.camara.gov.br/internet/deputado/Dep_Detalhe.asp' +
#     '?id=' + row['chamber_id']
#   if not File.exists?(filepath) then
#     `wget -O #{filepath} #{detail_url}`
#   end
#   if File.exists?(filepath) then
#     File.open(filepath, 'r') do |f|
#       reading = nil
#       f.each_line do |line|
#         line = iconv.iconv(line).strip
#         if not reading then
#           if line =~ PICTURE then
#             basename = $1
#             row['profile_picture'] = 'http://www.camara.gov.br' + basename
#           elsif line =~ FULL_NAME then
#             row['fullname'] = $1.strip
#             if line =~ FULL_NAME_LINE_FEED then
#               row['fullname'] = $1.strip
#             else
#               reading = 'fullname'
#             end
#           elsif line =~ SUBSCRIPTION_NUMBER then
#             row['subscription_number'] = $1
#           end
#         else
#           if line =~ END_OF_LINE then
#             row[reading] += ' ' + $1.strip
#             row[reading].strip!
#             reading = nil
#           else
#             row[reading] += ' ' + line
#             row[reading].strip!
#           end
#         end
#       end
#     end
#   end
#   legislators << row
# end


# field_names = ['chamber_id', 'nickname', 'subscription_number', 'state_code',
#                'party_code', 'profile_picture', 'fullname', 'in_office',
#                'office', 'building', 'phone', 'fax', 'email',
#                'reason_not_in_office']


# File.open(LEGISLATORS_CSV, 'w') do |f|
#   f << field_names.map { |field| "\"#{field}\""}.join(',') + "\n"
# end


# legislators.each do |leg|
#   fields = field_names.map{|field| leg[field]}
#   line = fields.map { |field| "\"#{field}\""}.join(',') + "\n"
#   File.open(LEGISLATORS_CSV, 'a') {|f| f << line }
# end


# # After updating the csv, downloads the legislators' pictures
# FasterCSV.foreach(LEGISLATORS_CSV, :headers => true) do |row|
#   url = row['profile_picture']
#   if url then
#     basename = url.split('/')[-1]
#     if basename then
#       path = File.join(DATA_PATH, '/source_data/legislators/photos')
#       filepath = File.join(path, basename)
#       if not File.exists?(filepath) then
#         `wget -O #{filepath} #{url}`
#       end
#     end
#   end
# end
