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
Welcome to Etsy Wishlist App. Please sign up or register!
```

Hurray! Users are now registering and signing in.

### Wishlist Table
I want users to create wishlists and have those wishlists belong to only those users. The items coming from Etsy will be included later when I both know more and figure out how to get the information into the DB. I will eventually want these items coming into the DB as their own table and associating with wishlists.

For now, the data modeling should be fairly straight forward. I just want a page for users to create and view their own wishlists.

First run the migration command
```ruby
rails g migration CreateWishlists title:string description:text total_cost:decimal user:belongs_to
```
And always double check the auto generated migration file
```ruby
class CreateWishlists < ActiveRecord::Migration
  def change
    create_table   :wishlists do |t|
      t.string     :title
      t.text       :description
      t.decimal    :total_cost
      t.belongs_to :user, index: true
    end
  end
end
```

Looks good. Run `rake db:migrate`  
Create the model
```ruby
# app/models/wishlist.rb
class Wishlist < ActiveRecord::Base
  belongs_to :user
end
```
Update the routes to nest wishlists inside users. Just add these lines in
```ruby
# config/routes.rb
resources :users do
  resources :wishlists
end
```

Then create the controller. This will change as we go on.
```ruby
class WishlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist, only:[:show, :edit, :update, :destroy]
  
  def index
    @wishlists = current_user.wishlists.all
  end

  def show
  end

  def edit
  end

  def new
    @wishlist = current_user.wishlists.new
  end

  def create
    @wishlist = current_user.wishlists.build(wishlist_params)
    if @wishlist.save
      redirect_to user_wishlists_path(current_user)
    else
      redirect_to :back
    end
  end

  def update
    if @wishlist.update(wishlist_params)
      redirect_to :show, notice: 'Wishlist was successfully updated.'
    else
      redirect_to :back
    end
  end

  def destroy
    @wishlist.destroy
    redirect_to user_wishlists_path
  end


  private

  def set_wishlist
    @wishlist = Wishlist.find(params[:id])
  end

  def wishlist_params
    params.require(:wishlist).permit(:title, :description, :user_id)
  end
end
```

Now finally, the view
```haml
/ app/views/home/index.html.haml
/ Put this near the bottom
- if user_signed_in?
  = link_to "See your Wishlists", user_wishlists_path(current_user)
```
```haml
/ app/views/wishlists/index.html.haml
Here is a list of your Wishlists
%br
- @wishlists.each do |w|
  =w.title
  %br
  = w.description
  %br
  %br
%br
= link_to "Create New Wishlist", new_user_wishlist_path
```
```haml
/ app/views/wishlists/new.html.haml
= form_for [current_user, @wishlist] do |f|
  = f.label :title
  %br
  = f.text_field :title
  %br
  = f.label :description
  %br
  = f.text_area :description
  %br
  = f.submit
%br
= link_to "Back", user_wishlists_path(current_user)
```

Great. Wishlists are now creating.

---

Let's quickly get them to delete now. I'm being very explicit with this and I'm sure there's a more "Rails" way of doing this.

Back in the view.
```haml
/ app/views/wishlists/index.html.haml
- @wishlists.each do |w|
  =w.title
  %br
  = w.description
  %br
  = button_to "Destroy", {:controller => :wishlists, :action => 'destroy', :id => w.id }, :method => :delete, data: { confirm: "Are you sure?" }
```

Hurray! We now have wishlists creating and deleting. Now onto creating items.

###Items

We first need to create a table and associations.
```ruby
rails g migration CreateItems