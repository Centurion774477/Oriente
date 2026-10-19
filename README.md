
In every new Rails app you have to go through and write a UsersController, User model, signup page, etc — and it's the same thing every time.
Oriente saves you the hassle of tediously creating everything needed for accounts.

With Oriente, you get:
- UsersController and SessionsController (and scaffolded methods)
- Full User model
- Sign up and log in page
- routes for signing up and logging in

You can also choose to scaffold a landing page. This will add a couple things that help you get started even faster:
- PagesController with a method
- pages/landing.html.erb
- Links to the sign up and log in page
- root path is set to PagesController#landing

I understand that this isn't for everyone, which is why I made it optional.
