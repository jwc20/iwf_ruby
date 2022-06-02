# frozen_string_literal: true

# Class for results for single athlete
class AthleteResult
  # name, athlete_id, nation, born, category, bweight, group,
  # rank_s, snatch1, snatch2, snatch3,
  # rank_cj, jerk1, jerk2, jerk3,
  # rank, snatch, jerk, total
  attr_accessor :name, :nation, :birthdate, :athlete_url,
                :category, :bweight, :group,
                :snatch1, :snatch2, :snatch3,
                :jerk1, :jerk2, :jerk3,
                :snatch, :jerk, :total,
                :rank_s, :rank_cj, :rank

  @@all = []

  def initialize
    @@all << self
  end

  def self.all
    @@all
  end

  def self.reset_all
    @@all.clear
  end
end
