require "rails_helper"

RSpec.describe Activity, type: :model do
  it "required a valid name" do
    invalid_activity = Activity.create(name: "invalid", data: {title: "foo"})
    valid_activity = Activity.create(name: Activity::VALID_NAMES.sample, data: {title: "foo"})

    expect(invalid_activity).not_to be_valid
    expect(valid_activity).to be_valid
  end
end
