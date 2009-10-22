#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'fileutils'
require 'open-uri'
require 'rubygems'
require 'faster_csv'


RAILS_ROOT = '../../../'
DATA_PATH = File.join(RAILS_ROOT, 'data/br_chamber/')
VOTES_CSV = File.join(DATA_PATH, 'votes.csv')
ROLL_CALLS_CSV = File.join(DATA_PATH, 'roll_calls.csv')

# the url is case-insensitive
base_url = "http://www.camara.gov.br/internet/plenario/result/votacao/" +
           "%s%0.2d.zip"


month_names = [
               'Janeiro',
               'Fevereiro',
               'Março',
               'Abril',
               'Maio',
               'Junho',
               'Julho',
               'Agosto',
               'Setembro',
               'Outubro',
               'Novembro',
               'Dezembro'
              ]


legislature = 53


start_year = 2007
end_year = 2010


(start_year..end_year).each do |year|
  month_names.each_with_index do |month, i|
    url = base_url % [month, year % 100]
    path = File.join(DATA_PATH, 'source_data', 'roll_call_votes', year.to_s,
                     "%0.2d" % (i + 1))
    filename = 'source.zip'
    filepath = File.join(path, filename)
    FileUtils.mkpath(path)
    `wget -O #{filepath} #{url}`
    `unzip -d #{path} #{filepath}`
  end
end


##
# Export votes to csv
field_lengths = [
                 ['legislative_session_type', 2],
                 ['legislative_session_number', 2],
                 ['legislative_session_ordinary_boolean', 1],
                 ['session_number', 3],
                 ['session_ordinary_boolean', 2],
                 ['roll_call_id', 7],
                 ['legislator_nickname', 40],
                 ['vote_value', 10],
                 ['party_acronym', 10],
                 ['state_name', 25],
                 ['legislator_subscription_number', 3]
                ]


filepaths = `find #{DATA_PATH}/source_data | grep -e "/LV"`.split("\n")


FasterCSV.open(VOTES_CSV, 'w', :headers => true) do |csv|
  csv << field_lengths.map{|name, length| name }

  filepaths.each do |filepath|
    File.open(filepath) do |file|
      file.each_line do |line|
        i = 0
        csv_line = []

        field_lengths.each do |name, length|
          csv_line << line[i...(i+length)].strip
          i += length
        end

        csv << csv_line
      end
    end
  end
end


##
# Export roll_calls to csv
field_names = [
               'legislative_session_type',
               'legislative_session_number',
               'legislative_session_ordinary_boolean',
               'session_number',
               'session_ordinary_boolean',
               'roll_call_id',
               'end_date',
               'end_time',
               'president',
               'yes_total',
               'no_total',
               'abstension_total',
               'obstruction_total',
               'blank_total',
               'president_votes_total',
               'voters_total',
               'bill_type',
               'bill_number',
               'bill_year',
               'title'
        ]


filepaths = `find source_data | grep -e "/HE"`.split("\n").reject do |f|
  f[-10..-5] == '000000' # we don't want sessions where nothing was voted
end


FasterCSV.open(ROLL_CALLS_CSV, 'w', :headers => true) do |csv|
  csv << field_names

  filepaths.each do |filepath|
    File.open(filepath) do |file|
      csv_line = []

      # legislative_session_type
      # legislative_session_number
      # legislative_session_ordinary_boolean
      # session_number
      # session_ordinary_boolean
      line = file.readline
      line =~ /(..)(..)(.)(...)(.)/
      csv_line += [$1, $2, $3, $4, $5]

      # roll_call_id
      # end_date
      # end_time
      # president
      # yes_total
      # no_total
      # abstension_total
      # obstruction_total
      # blank_total
      # president_votes_total
      # voters_total
      11.times { csv_line << file.readline.strip }

      # bill_type
      # bill_number
      # bill_year
      # title
      line = file.readline
      if line =~ /^(.....)...(\d+)\/(\d+) - (.*)/u
        csv_line += [$1, $2, $3, $4].map{|i| i ? i.strip : '' }
      else
        csv_line += ['', '', '', line.strip]
      end

      csv << csv_line
    end
  end
end
