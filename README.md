About
===
Built to test my skills in external API integration. I'm going to redo a project from The Iron Yard and build an app that integrates [Etsy](www.etsy.com)'s API that lets users log in, create wishlists, and add items from etsy into that wishlist. Maybe if I'm crazy enough, I'll try posting it to facebook.

Development
===

### Initial Setup
Create the new app with postgresql as default database automatically
```ruby
rails new etsywishlistparttwo --database=postgresql
```
Configure Gemfile for haml
```ruby
# Gemfile
gem 'haml'
```
And then configure a quick home page. I like to call it 'home'
```ruby
# config/routes.rb
Rails.application.routes.draw do
  root 'home#index'
end
```

Add the controller by creating a new file in the controller folder called `home`
```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
  end
end
```
And add the new view page by creating a folder called home and a new file called `index.html.haml`
```haml
/ app/views/home/index.html.haml
Hello World!
```

Success! The app now has a home page and is running.

### User Registration
We need to have users log in and access their wishlists. Fastest way is to use the devise gem

```ruby
# Gemfile
gem 'devise'
```

run `bundle install` and then
```ruby
rails generate devise:install
```
Which installs an initialler and spits out a list of all of devises configuration options. Go through them and make sure you follow them.  
I already have the default root page.  
I did have to copy `config.action_mailer.default_url_options = { host: 'localhost:3000' }` 
and `<p class="notice"><%= notice %></p>`
     `<p class="alert"><%= alert %></p>`

After that run
```ruby
rails generate devise USER
```
Then so we can see what we're working with
```ruby
rails g devise:views
```

All this generates a lot of stuff. But, for now we just want to keep things simple so we can start working on the APIs. Devise has generated a migration file for us. We can leave it alone for now. Once I know more about my app, I might add in the user's name and such so let's run `rake db:migrate`. 

In a previous [app](https://github.com/RyanSnodgrass/notredame_club_membership_app) I built, I thought Devise had some sort of generator that I couldn't find in time to hook everything into the home page. I am now under the impression this is half true. Devise does generate everything- registration, sign in, password reset - you just have to hook everything into the devise controller. I swear there was a generator and I've been looking over the docs as best I can. Maybe I'm just not seeing it. Anyway, the links I want to copy over from the old app are as follows
```haml
/ make sure to rename the extension from erb to haml
/ app/views/layouts/application.html.haml
  %body
    - if notice != nil
      %p.notice= notice
    - if alert != nil       
      %p.alert= alert

    = yield
    %br
    - unless request.env['PATH_INFO']  == "/"
      = link_to "Go Back Home", root_path, :class => 'navbar-link'
```
```haml
/ app/views/home/index.html.haml
%ul
  - if user_signed_in?
    %li
      %a{href: edit_user_registration_path} Edit Profile
    %li
      = link_to "Logout", destroy_user_session_path, method: :delete, :class => 'smoothscroll'
    %li
      %h4
        Logged in as #{current_user.email}
  - else
    %li
      = link_to "Sign up", new_user_registration_path, :class => 'navbar-link'
    %li
      = link_to "Login", new_user_session_path, :class => 'navbar-link'
Hello World
```