Fabricator(:project) do
  name 'project1'
  description ''
  stages do |project|
    [
      Fabricate(:stage, project: project, name: "#{project[:name]} - stage1"),
      Fabricate(:stage, project: project, name: "#{project[:name]} - stage2")
    ]
  end
end
