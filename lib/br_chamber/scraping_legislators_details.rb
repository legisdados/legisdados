#!/usr/bin/env ruby
require 'rubygems'
require 'faster_csv'
require 'iconv'
require 'fileutils'

RAILS_ROOT = '../../../'
DATA_PATH = File.join(RAILS_ROOT, 'data/br_chamber/')
LEGISLATORS_CSV = File.join(DATA_PATH, 'legislators.csv')


iconv = Iconv.new('UTF-8', 'iso-8859-1')


PICTURE = Regexp.new('^<img src=\"(\/internet\/deputado\/fotos\/[^.]*.jpg)"' +

                     '.*alt=\"Foto do Deputado.*' + "$")
FULL_NAME = /^<td>Nome Civil: (.*)$/
FULL_NAME_LINE_FEED = /^<td>Nome Civil: (.*)<[bB][rR]>$/
SUBSCRIPTION_NUMBER = Regexp.new('^<A HREF="RelVotacoes.asp[?]nuLegislatura' +

                                 '=\d+&nuMatricula=(\d+).*' + "$")
END_OF_LINE = /^(.*)<[bB][rR]>$/


legislators = []


# Updates profile info for each legislator
FasterCSV.foreach(LEGISLATORS_CSV, :headers => true) do |row|
  puts row['nickname']
  path = File.join(DATA_PATH, '/source_data/legislators/details')
  FileUtils.mkpath(path)
  filepath = File.join(path, row['chamber_id'] + '.html')
  detail_url = 'http://www.camara.gov.br/internet/deputado/Dep_Detalhe.asp' +
    '?id=' + row['chamber_id']
  if not File.exists?(filepath) then
    `wget -O #{filepath} #{detail_url}`
  end
  if File.exists?(filepath) then
    File.open(filepath, 'r') do |f|
      reading = nil
      f.each_line do |line|
        line = iconv.iconv(line).strip
        if not reading then
          if line =~ PICTURE then
            basename = $1
            row['profile_picture'] = 'http://www.camara.gov.br' + basename
          elsif line =~ FULL_NAME then
            row['fullname'] = $1.strip
            if line =~ FULL_NAME_LINE_FEED then
              row['fullname'] = $1.strip
            else
              reading = 'fullname'
            end
          elsif line =~ SUBSCRIPTION_NUMBER then
            row['subscription_number'] = $1
          end
        else
          if line =~ END_OF_LINE then
            row[reading] += ' ' + $1.strip
            row[reading].strip!
            reading = nil
          else
            row[reading] += ' ' + line
            row[reading].strip!
          end
        end
      end
    end
  end
  legislators << row
end


field_names = ['chamber_id', 'nickname', 'subscription_number', 'state_code',
               'party_code', 'profile_picture', 'fullname', 'in_office',
               'office', 'building', 'phone', 'fax', 'email',
               'reason_not_in_office']


File.open(LEGISLATORS_CSV, 'w') do |f|
  f << field_names.map { |field| "\"#{field}\""}.join(',') + "\n"
end


legislators.each do |leg|
  fields = field_names.map{|field| leg[field]}
  line = fields.map { |field| "\"#{field}\""}.join(',') + "\n"
  File.open(LEGISLATORS_CSV, 'a') {|f| f << line }
end


# After updating the csv, downloads the legislators' pictures
FasterCSV.foreach(LEGISLATORS_CSV, :headers => true) do |row|
  url = row['profile_picture']
  if url then
    basename = url.split('/')[-1]
    if basename then
      path = File.join(DATA_PATH, '/source_data/legislators/photos')
      filepath = File.join(path, basename)
      if not File.exists?(filepath) then
        `wget -O #{filepath} #{url}`
      end
    end
  end
end
