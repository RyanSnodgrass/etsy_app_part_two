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

After that run
```ruby
rails generate devise USER
```