Fabricator(:project) do
  name 'project1'
  description ''
  stages(count: 2) do |project, i|
    Fabricate(:stage, name: "#{project[:name]} - stage#{i}") do
      tasks(count: 3) do |step, j|
        Fabricate(:task, name: "#{step[:name]} - task#{j}") do
          steps(count: 4) do |task, k|
            Fabricate(:step, name: "#{task[:name]} - step#{k}")
          end
        end
      end
    end
  end
end
