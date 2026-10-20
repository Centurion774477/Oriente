# frozen_string_literal: true

require "tty-prompt"
require_relative "engine"


def oriente(prompt)
  puts "Oriente: an opinionated Rails scaffolder"
  command = prompt.select("What do you want to do?", ["Run Oriente", "See what Oriente will do","Exit"])

  if command == "Run Oriente"
    puts "Do you want to run Oriente loudly or quietly?"
    puts "Loudly will print out all files created and commands ran; quietly will not."
    verbosity = prompt.select("Choose:", %w[Loudly Quietly])
    if verbosity == "Loudly"
      Oriente.run(verbose: true)
    else
      Oriente.run
    end

    puts "\nWould you like to create a landing page?"
    create_landing = prompt.yes?("This will add a landing page to the root path with signup and login buttons.")

    if create_landing then Oriente.create_landing(verbosity) end
    puts "Done scaffolding!"
    puts "Note: in app/controllers/users_controller.rb, you have to fill in the redirect yourself, since it is app specific."
    puts "Cheers!"
  elsif command == "Exit"
    exit
  else
    puts <<~END
      Here is a list of all the files/commands Oriente will create, 
      and what goes inside them:
      
      Controllers:
      - UsersController (signup)
      - SessionsController (login)
    
      Methods:
      - UsersController#new
      - UsersController#create
  
      - SessionsController#new
      - SessionsController#create
      - SessionsController#destroy
  
      Routes:
      - resources :users, only: %i[new create]
      - resource :session, only: %i[new create destroy]
  
      If you choose to generate a landing page too, you will also receive the following:
      
      - PagesController
      - PagesController#landing
      - pages/landing.html.erb
  
      Inside the view, there will be a simple header and links to signup and login.
    END
  end
end

# allow the user to use ^C to exit without throwing a huge stacktrace
begin
  prompt = TTY::Prompt.new
  oriente(prompt)
rescue TTY::Reader::InputInterrupt
  exit
end
