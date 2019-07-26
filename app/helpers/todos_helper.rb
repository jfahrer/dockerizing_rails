module TodosHelper
  def filter_names
    {
      "all_todos" => "All",
      "active" => "Active",
      "completed" => "Completed",
    }
  end
end
