Fabricator(:stage) do
  name 'stage1'
  description ''
  tasks do |stage|
    [
      Fabricate(:task, stage: stage, name: "#{stage[:name]} - task1"),
      Fabricate(:task, stage: stage, name: "#{stage[:name]} - task2")
    ]
  end
end
