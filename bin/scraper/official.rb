#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    PREFIXES = %w[Dr Lt Col the Hon].freeze

    def name
      unprefixed_name.sub(/,.*/, '')
    end

    def position
      tds[2].text.split(/(?:and (?=Minister)|&)/).map(&:tidy)
    end

    private

    def tds
      noko.css('td')
    end

    def raw_name
      tds[1].text.tidy
    end

    def unprefixed_name
      PREFIXES.reduce(raw_name) { |current, prefix| current.sub(/#{prefix}.? /i, '') }
    end
  end

  class Members
    def member_container
      noko.css('.article-desc table').xpath('.//tr[td]')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
