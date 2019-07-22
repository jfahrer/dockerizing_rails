class ScoreCalculator
  POINTS = {
    todo_created: 1,
    todo_deleted: -1,
    todo_marked_as_complete: 5,
    todo_marked_as_active: -5,
  }

  def self.call(date)
    total_points = POINTS.sum { |activity_name, points|
      Activity.where(created_at: [date.beginning_of_day..date.end_of_day], name: activity_name).count * points
    }

    score = Score.find_or_initialize_by(date: date)
    score.points = total_points
    score.save!
  end
end
