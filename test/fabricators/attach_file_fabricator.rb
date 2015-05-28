Fabricator(:attach_file) do
  platform :jingdong
  step { Fabricate(:step) }
end
