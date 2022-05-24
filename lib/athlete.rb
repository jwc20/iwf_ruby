class Athlete
  # name, athlete_id, nation, born, category, bweight, group,
  # rank_s, snatch1, snatch2, snatch3,
  # rank_cj, jerk1, jerk2, jerk3,
  # rank, snatch, jerk, total
  attr_accessor :name, :athlete_id, :nation, :born, :category, :bweight, :group, :rank_s, :snatch1, :snatch2, :snatch3, :rank_cj, :jerk1, :jerk2, :jerk3, :rank, :snatch, :jerk, :total

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
