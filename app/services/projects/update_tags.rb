require 'git'

module Services
  module Projects
    class UpdateTags < Services::Base
      check_uniqueness!

      def call(id_or_object)
        project = find_object(id_or_object)
        git = Git.open(project.local_path)
        3.tries on: Git::GitExecuteError, delay: 1 do
          git.fetch 'origin', tags: true
        end
        tags = git.tags.each_with_object({}) do |tag, hash|
          hash[tag.name] = git.gcommit(tag.sha).date
        end
        # Sort tags by date
        tags = Hash[*tags.sort_by(&:last).reverse.flatten]
        project.tags = tags
        project.save!
        project
      end
    end
  end
end
