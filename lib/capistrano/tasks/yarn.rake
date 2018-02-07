namespace :yarn do
  desc <<-DESC
        Install the project dependencies via yarn. By default, devDependencies \
        will not be installed. The install command is executed \
        with the --production, --silent and --no-spin flags.

        You can override any of these defaults by setting the variables shown below.

          set :yarn_target_path, nil
          set :yarn_flags, '--production'
          set :yarn_roles, :all
          set :yarn_env_variables, {}
          set :yarn_bin, :yarn
    DESC
  task :install do
    on roles fetch(:yarn_roles) do
      within fetch(:yarn_target_path, release_path) do
        with fetch(:yarn_env_variables, {}) do
          execute fetch(:yarn_bin), 'install', fetch(:yarn_flags)
        end
      end
    end
  end

  desc <<-DESC
        Run the package task via yarn. By default, build \
        will be execute.
    DESC
  task :run do
    on roles fetch(:yarn_roles) do
      within fetch(:yarn_target_path, release_path) do
        options = [
          fetch(:yarn_tasks, 'build')
        ]
        execute fetch(:yarn_bin), :run, options
      end
    end
  end

  before 'deploy:updated', 'yarn:install'
  before 'deploy:updated', 'yarn:run'

  desc <<-DESC
        Remove extraneous packages via yarn. This command is executed within \
        the same context as yarn install using the yarn_roles and yarn_target_path \
        variables.

        By default prune will be executed with the --production flag.  You can \
        override this default by setting the variable shown below.

          set :yarn_prune_flags, '--production'

        This task is strictly opt-in.  If you want to run it on every deployment \
        before you run yarn install, add the following to your deploy.rb.

          before 'yarn:install', 'yarn:prune'
    DESC
  task :prune do
    on roles fetch(:yarn_roles) do
      within fetch(:yarn_target_path, release_path) do
        execute fetch(:yarn_bin), 'prune', fetch(:yarn_prune_flags)
      end
    end
  end

  desc <<-DESC
        Rebuild via yarn. This command is executed within the same context \
        as yarn install using the yarn_roles and yarn_target_path \
        variables.

        This task is strictly opt-in. The main reason you'll want to run this \
        would be after changing yarn versions on the server.
    DESC
  task :rebuild do
    on roles fetch(:yarn_roles) do
      within fetch(:yarn_target_path, release_path) do
        with fetch(:yarn_env_variables, {}) do
          execute fetch(:yarn_bin), 'rebuild'
        end
      end
    end
  end
end

namespace :load do
  task :defaults do
    set :yarn_tasks, nil
    set :yarn_flags, %w(--production)
    set :yarn_prune_flags, ''
    set :yarn_roles, :all
    set :yarn_bin, :yarn
  end
end
