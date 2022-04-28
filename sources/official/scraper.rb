#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      Name.new(
        full:     tds[1].text.tidy,
        prefixes: %w[Dr Lt Col the Hon]
      ).short.sub(/,.*/, '')
    end

    def position
      tds[2].text.split(/(?:and (?=Minister)|&)/).map(&:tidy)
    end

    private

    def tds
      noko.css('td')
    end
  end

  class Members
    def member_container
      noko.css('.article-desc table').xpath('.//tr[td]')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
