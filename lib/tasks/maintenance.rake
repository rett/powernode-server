namespace :maintenance do
  desc 'Run all maintenance tasks'
  task :all => [:clean_arch, :clean_modules]

  desc 'Clean architecture directory'
  task :clean_arch => :environment do
    puts "Cleaning architectures directory #{Powernode.config.arch_dir}..."
    NodeArchitecture.all.each do |node_architecture|
      NodeArchitecture::COMPONENTS.each do |component|
        if (component_file_name = node_architecture["#{component}_file_name".to_sym])
          component_file = File.join(Powernode.config.arch_dir, node_architecture.uuid_partition, component_file_name)
          FileUtils.touch(component_file)
        end
      end
    end
    system *%W(find #{Powernode.config.arch_dir} -type f -mtime #{Powernode.config.data_expiration} -delete)
    system *%W(find #{Powernode.config.arch_dir} -type d -empty -delete)
  end

  desc 'Clean module directory'
  task :clean_modules => :environment do
    puts "Cleaning modules directory #{Powernode.config.module_dir}..."
    NodeModule.all.each do |node_module|
      node_module.versions.each do |version|
        if version.data_file_name
          module_file = File.join(Powernode.config.module_dir, node_module.uuid_partition, version.data_file_name)
          FileUtils.touch(module_file)
        end
      end
    end
    system *%W(find #{Powernode.config.module_dir} -type f -mtime #{Powernode.config.data_expiration} -delete)
    system *%W(find #{Powernode.config.module_dir} -type d -empty -delete)
  end


end
