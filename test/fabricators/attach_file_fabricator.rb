Fabricator(:attach_file) do
  organization :jingdong
  step { Fabricate(:step) }
end
