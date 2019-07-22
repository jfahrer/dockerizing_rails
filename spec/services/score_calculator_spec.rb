require "rails_helper"

RSpec.describe ScoreCalculator do
  describe ".call" do
    it "generates the total score for a given date" do
      start_time = Time.now.beginning_of_day

      Activity.create!(name: "todo_created", data: {title: "old todo"}, created_at: 48.hours.ago)
      Activity.create!(name: "todo_created", data: {title: "actual todo"}, created_at: start_time + 1.hour)
      Activity.create!(name: "todo_created", data: {title: "deleted todo"}, created_at: start_time + 1.hour)
      Activity.create!(name: "todo_deleted", data: {title: "deleted todo"}, created_at: start_time + 1.hour)
      Activity.create!(name: "todo_marked_as_complete", data: {title: "actual todo"}, created_at: start_time + 2.hour)
      Activity.create!(name: "todo_marked_as_active", data: {title: "actual todo"}, created_at: start_time + 3.hour)
      Activity.create!(name: "todo_marked_as_complete", data: {title: "actual todo"}, created_at: start_time + 4.hour)

      expect {
        described_class.call(start_time.to_date)
      }.to change(Score, :count).by(1)
      expect(Score.last.points).to eq(6)
    end

    it "updates existing scores" do
      date = Date.today
      score = Score.create(date: date, points: 0)
      Activity.create!(name: "todo_created", data: {title: "actual todo"}, created_at: date.beginning_of_day)

      expect {
        described_class.call(date)
      }.not_to change(Score, :count)
      expect(score.reload.points).to eq(1)
    end
  end
end
