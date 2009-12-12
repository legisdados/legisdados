#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'fileutils'
require 'iconv'
require 'fastercsv'
require File.expand_path(File.join(File.dirname( __FILE__),
                                   'scraper_common'))


class RollCallScraper
  include ScrapingHelper

  def initialize(opts={})
    @options = opts

    # Base directory where parsed data is going to be stored
    @data_path = File.expand_path(@options[:data_dir])

    # Directory to store the raw zip files we're downloading
    @source_data_path = File.expand_path(@options[:source_data_dir])

    # Pages come in iso-8859-1, we need utf-8
    @iconv = Iconv.new('UTF-8', 'iso-8859-1')

    # the url is case-insensitive
    @base_url = "http://www.camara.gov.br/internet/plenario/result/votacao/" +
           "%s%0.2d.zip"
  end

  def run!
    get! unless @options[:noget]
    parse! unless @options[:noparse]
  end

  def get!
    FileUtils.mkpath(@source_data_path)
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

    Dir.chdir(@source_data_path) do
      (start_year..end_year).each do |year|
        month_names.each_with_index do |month, i|
          url = @base_url % [month, year % 100]
          puts `wget -x #{url}`
        end
      end
    end
  end

  def parse!
    input_path = File.join(@source_data_path, url_path(@base_url))

    # Path where we store the final roll call json data
    output_path = File.join(@data_path, 'br', 'chamber', '2007-2010',
                            'roll_calls')
    FileUtils.mkpath(output_path)

    puts input_path, output_path

    roll_calls_csv = File.join(output_path, 'roll_calls.csv')
    votes_csv = File.join(output_path, 'votes.csv')

    Dir.chdir(input_path) do
      `ls -t --reverse *.zip`.each do |zip_file|
        puts `unzip #{zip_file}`
      end
    end

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


    filepaths = `find #{input_path} | grep -e "/HECD"`.split("\n").reject {|f|
      f[-10..-5] == '000000' # we don't want sessions where nothing was voted
    }.sort

    FasterCSV.open(roll_calls_csv, 'w', :headers => true) do |csv|
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

    filepaths = `find #{input_path} | grep -e "/LVCD"`.split("\n").sort

    FasterCSV.open(votes_csv, 'w', :headers => true) do |csv|
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

    Dir.chdir(input_path) do
      FileUtils.rm(Dir['*.txt'])
      FileUtils.rm(Dir['*.TXT'])
    end
  end
end

if __FILE__ == $0
  options = ScraperOptions.parse(ARGV)
  puts ARGV.inspect
  puts options.inspect
  f = RollCallScraper.new(options)
  f.run!
end
