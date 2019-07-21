class ActivitiesController < ApplicationController
  def index
    @activities = Activity.order(created_at: :desc).limit(25)
    @scores = Score.order(created_at: :desc).limit(7)
  end
end
