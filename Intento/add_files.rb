require 'xcodeproj'

project_path = 'Intento.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Add SupabaseProductDTO.swift
file_path_1 = 'Intento/Core/Services/Catalog/SupabaseProductDTO.swift'
group_1 = project.main_group.find_subpath('Intento/Core/Services/Catalog', true)
file_ref_1 = group_1.new_reference(file_path_1)
target.add_file_references([file_ref_1])

# Add SupabaseProductCatalogService.swift
file_path_2 = 'Intento/Core/Services/Catalog/SupabaseProductCatalogService.swift'
file_ref_2 = group_1.new_reference(file_path_2)
target.add_file_references([file_ref_2])

project.save
puts "Successfully added files to Xcode project"
