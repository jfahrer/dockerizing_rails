class ScoreGenerationJob
  include Sidekiq::Worker

  def perform(date_string)
    ScoreCalculator.call(date_string.to_date)
  end
end
