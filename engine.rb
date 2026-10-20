# frozen_string_literal: true

require "fileutils"

class Oriente
  def self.run(verbose: false)
    unless Dir.exist? "app"
      puts <<~END
      Oriente must be ran in a Rails project.

      To scaffold a Rails app, run:
      rails new <app_name>
      END
      exit
    end

    create_controllers(verbose)
    create_models(verbose)
    create_views(verbose)
    add_routes(verbose)

    `rails db:migrate`

    unless File.exist? "Gemfile"
      content = File.read "Gemfile"
      content.gsub!('# gem "bcrypt", "~> 3.1.7"', 'gem "bcrypt", "~> 3.1.7"')
      File.write("Gemfile", content)
    end

    `bundle install --quiet`

    add_current_user_helper(verbose)
  end

  def self.add_current_user_helper(verbose)
    path = File.join "app", "controllers", "application_controller.rb"

    return unless File.exist? path

    contents = File.read path

    return if contents.include? "current_user"

    injection = <<'INJECTION'
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
INJECTION

    contents.gsub! "class ApplicationController < ActionController::Base", "class ApplicationController < ActionController::Base\n#{injection}"

    File.write path, contents

    puts "\n~> Added current_user helper method to ApplicationController" if verbose
  end

  def self.create_landing(verbose)
    controller_path = File.join("app", "controllers", "pages_controller.rb")

    controller_contents = <<~END
      class PagesController < ApplicationController
        def landing
        end
      end 
    END

    File.write controller_path, controller_contents
    puts "~> Created PagesController" if verbose

    view_path = File.join("app", "views", "pages")

    view_contents = <<~END
    <h1>Your site</h1>
    
    <%= link_to "Sign up", "/users/new" %>
    <%= link_to "Log in", "/sessions/new" %>
    END

    # TODO add duplicate checks here

    FileUtils.mkdir_p view_path unless Dir.exist? view_path

    view_file = File.join(view_path, "landing.html.erb")

    File.write view_file, view_contents unless File.exist? view_file

    puts "~> Created landing page" if verbose

    routes_path = File.join("config", "routes.rb")

    unless File.exist? routes_path
      routes_contents = File.read routes_path

      routes_contents.gsub!("Rails.application.routes.draw do", "Rails.application.routes.draw do\n  root to: 'pages#landing'\n")

      File.write routes_path, routes_contents

      puts "~> added root route"
    end
  end

  private

  def self.create_controllers(verbose)
    user_contents = <<~END
      class UsersController < ApplicationController
        def new
          @user = User.new
        end

        def create
          @user = User.new user_params

          if @user.save
            @project = Project.create(user_id: @user.id)
            session[:user_id] = @user.id
            # add your redirect here!
          else
            render :new, status: :unprocessable_entity
          end
        end
    
        private

        def user_params
          # add any special params here!
          params.require(:user).permit(:name, :email, :password)
        end
      end
    END
    if File.exist? File.join("app", "controllers", "users_controller.rb")
      puts "UsersController already exists — skipping" if verbose
    else
      File.write(File.join("app", "controllers", "users_controller.rb"), user_contents)
    end

    session_contents = <<~END
      class SessionsController < ApplicationController
        def new
        end

        def create
        end

        def destroy
        end
      end
    END

    if File.exist? File.join("app", "controllers", "sessions_controller.rb")
      puts "SessionsController already exists — skipping" if verbose
    else
      File.write(File.join("app", "controllers", "sessions_controller.rb"), session_contents)
      puts "~> Scaffolded UsersController and SessionsController" if verbose
    end
  end

  def self.create_models(verbose)
    if File.exist? File.join("app", "models", "user.rb")
      puts "User model already exists — skipping" if verbose
    else
      `rails g model User name:string email:string password:string`
    end

    path = File.join("app", "models", "user.rb")

    unless File.exist? path
      model_contents = File.read path

      injection = <<~END
          has_secure_password
    
          validates :email, presence: true, uniqueness: true
          validates :name, presence: true
      END

      unless model_contents.include? "has_secure_password"
        model_contents.gsub! "class User < ApplicationRecord\n", "class User < ApplicationRecord\n#{injection}"
        File.write path, model_contents
        puts "~> Scaffolded User model" if verbose
      end
    end
  end

  def self.create_views(verbose)
    views_path = File.join("app", "views")

    if Dir.exist? File.join(views_path, "users")
      puts "users view directory already exists — skipping" if verbose
    else
      FileUtils.mkdir File.join(views_path, "users")
    end

    users_new_content = <<~END
    <h1>
      Sign up
    </h1>

    <% if @user.errors.any? %>
      <ul>
        <% @user.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    <% end %>
    
    <%= form_with model: @user do |form| %>
      <%= form.label :name %> <br>
      <%= form.text_field :name, autofocus: true %> <br>
      
      <%= form.label :email %> <br>
      <%= form.email_field :email %> <br>
    
      <%= form.label :password %> <br>
      <%= form.password_field :password %> <br>
    
      <br>
      <%= form.submit "Create Account" %>
    <% end %>
    END

    if File.exist? File.join(views_path, "users", "new.html.erb")
      puts "users/new.html.erb already exists — skipping"
    else
      File.write File.join(views_path, "users", "new.html.erb"), users_new_content
      puts "~> Scaffolded users/new.html.erb" if verbose
    end

    if Dir.exist? File.join(views_path, "sessions")
      puts "sessions view directory already exists — skipping" if verbose
    else
      FileUtils.mkdir File.join(views_path, "sessions")
    end

    sessions_new_content = <<~END
    <h1>
      Sign in
    </h1>
    
    <%= flash[:alert] %>
    
    <%= form_with url: "/sessions" do |form| %>
      <%= form.label :email %> <br>
      <%= form.email_field :email, autofocus: true %> <br>
    
      <%= form.label :password %> <br>
      <%= form.password_field :password %> <br>
    
      <br>
      <%= form.submit "Sign in" %>
    <% end %>
    END

    if File.exist? File.join(views_path, "sessions", "new.html.erb")
      puts "sessions/new.html.erb already exists — skipping"
    else
      File.write File.join(views_path, "sessions", "new.html.erb"), sessions_new_content
      puts "~> Scaffolded sessions/new.html.erb" if verbose
    end
  end

  def self.add_routes(verbose)
    routes = File.join "config", "routes.rb"

    unless File.exist? routes
      route_content = File.read routes

      injection = <<~END
          resources :users, only: %i[new create]
          resource :session, only: %i[new create destroy]
      END

      unless route_content.include? "resources :users"
        route_content.gsub!("Rails.application.routes.draw do", "Rails.application.routes.draw do\n#{injection}")
        File.write routes, route_content
        puts "~> Scaffolded routes" if verbose
      end
    end
  end
end