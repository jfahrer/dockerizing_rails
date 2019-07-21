require "rails_helper"

RSpec.describe "Acitivites", type: :request do
  describe "GET /activities" do
    it "lists activities" do
      Activity::VALID_NAMES.each do |name|
        Activity.create(name: name, data: {title: "laundry"})
      end

      get activities_path

      expect(response).to have_http_status(200)
      expect(response.body).to include("laundry")
    end
  end
end
