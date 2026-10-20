
In every new Rails app you have to go through and write a UsersController, User model, signup page, etc — and it's the same thing every time.
Oriente saves you the hassle of tediously creating everything needed for accounts.

With Oriente, you get:
- UsersController and SessionsController (and scaffolded methods)
- Full User model
- Sign up and log in page
- routes for signing up and logging in
- current_user helper method defined in ApplicationController

You can also choose to scaffold a landing page. This will add a couple things that help you get started even faster:
- PagesController with a method
- pages/landing.html.erb
- Links to the sign up and log in page
- root path is set to PagesController#landing

I understand that this isn't for everyone, which is why I made it optional.

Everything scaffolded in Oriente comes from what I've needed in my own apps. 
It's not designed for really specific apps where you may need more authentication, 
but for general apps Oriente will save you ~15 minutes of work.
