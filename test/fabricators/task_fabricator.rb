Fabricator(:task) do
  name 'step1'
  description ''
  steps do |task|
    [
      Fabricate(:step, task: task, name: "#{task[:name]} - step1"),
      Fabricate(:step, task: task, name: "#{task[:name]} - step2"),
      Fabricate(:step, task: task, name: "#{task[:name]} - step3")
    ]
  end
end
