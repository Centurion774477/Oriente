# frozen_string_literal: true

require "tty-prompt"
require_relative "engine"

prompt = TTY::Prompt.new

puts "Oriente"
command = prompt.select("What do you want to do?", ["See what Oriente will do", "Run Oriente"])

if command == "Run Oriente"
  puts "Do you want to run Oriente loudly or quietly?"
  puts "Loudly will print out all files created and commands ran; quietly will not."
  verbosity = prompt.select("Choose:", %w[Loudly Quietly])
  if verbosity == "Loudly"
    Oriente.run(verbose: true)
  else
    Oriente.run
  end

  puts "Would you like to create a landing page?"
  create_landing = prompt.yes?("This will add a landing page to the root path with signup and login buttons.")

  if create_landing then Oriente.create_landing(verbosity) end
  puts "Done scaffolding!"
  puts "Note: in app/controllers/users_controller.rb, you have to fill in your redirect."
  puts "Cheers!"
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
  END
end