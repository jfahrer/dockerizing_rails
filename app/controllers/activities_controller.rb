class ActivitiesController < ApplicationController
  def create
    activity = Activity.new(activity_params)
    unless activity.save
      flash[:notice] = activity.errors.full_messages.to_sentence
    end
    redirect_path = activity.book.present? ? book_path(activity.book) : root_path
    redirect_to redirect_path
  end

  private

  def activity_params
    params.require(:activity).permit(:book_id, :pages_read)
  end
end
