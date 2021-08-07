#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  # details for an individual member
  class Member < Scraped::HTML
    PREFIXES = %w[Dr Lt Col the Hon].freeze

    field :name do
      unprefixed_name.sub(/,.*/, '')
    end

    field :position do
      tds[2].text.split(/(?:and (?=Minister)|&)/).map(&:tidy)
    end

    private

    def tds
      noko.css('td')
    end

    def full_name
      tds[1].text.tidy
    end

    def unprefixed_name
      PREFIXES.reduce(full_name) { |current, prefix| current.sub(/#{prefix}.? /i, '') }
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      member_container.flat_map do |member|
        data = fragment(member => Member).to_h
        [data.delete(:position)].flatten.map { |posn| data.merge(position: posn) }
      end
    end

    private

    def member_container
      noko.css('.article-desc table').xpath('.//tr[td]')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
