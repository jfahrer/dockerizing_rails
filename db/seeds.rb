# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Todo.create!(title: "Laundry", created_at: 51.hours.ago)
Todo.create!(title: "Bring the trash out", completed: true, created_at: 51.3.hours.ago)
Todo.create!(title: "Shopping", created_at: 1.hours.ago)

Activity.create!([
  {name: "todo_created", data: {title: "Laundry"}, created_at: 51.hours.ago},
  {name: "todo_created", data: {title: "Bring the trash out"}, created_at: 51.3.hours.ago},
  {name: "todo_marked_as_complete", data: {title: "Bring the trash out"}, created_at: 48.1.hours.ago},
  {name: "todo_created", data: {title: "Pick the kids up from soccer"}, created_at: 25.3.hours.ago},
  {name: "todo_deleted", data: {title: "Pick the kids up from soccer"}, created_at: 24.0.hours.ago},
  {name: "todo_created", data: {title: "Shopping"}, created_at: 1.hours.ago},
])

0.upto(3) do |i|
  date = Date.today - i.days
  ScoreCalculator.call(date)
end
