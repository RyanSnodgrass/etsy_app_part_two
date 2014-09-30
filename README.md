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

###Items Table

We first need to create a table and associations. I will eventually want to save pics of items from Etsy into the DB, but thats for a later phase as it involves working with the wonky paperclip or finicky carrierwave.  
For now just generate a simple table
```ruby
rails g migration CreateItems name:string description:text cost:decimal wishlist:belongs_to
```
And again check the generated migration file
```ruby
# db/migrate/20140930155536_create_items.rb
class CreateItems < ActiveRecord::Migration
  def change
    create_table   :items do |t|
      t.string     :name
      t.text       :description
      t.decimal    :cost
      t.belongs_to :wishlist, index: true
    end
  end
end
```
Looks good. `rake db:migrate`

Create the model
```ruby
# app/models/item.rb
class Item < ActiveRecord::Base
  belongs_to :wishlist
end
```
And the associtations necessary.
```ruby
# app/models/wishlist.rb
class Wishlist < ActiveRecord::Base
  belongs_to :user
  has_many   :items
end

# app/models/user.rb
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :wishlists
  has_many :items, through: :wishlists
end
```

Today I learned that you don't have to associate back up the table records. I thought I had to have a `belongs_to :user, through: :wishlist` line in the item table. Looking through the [ruby guides](http://guides.rubyonrails.org/association_basics.html#the-has-many-through-association) again I realize that rails knows the association automatically.

Create the resources routes. According to again [ruby guides](http://guides.rubyonrails.org/routing.html#limits-to-nesting), it is bad practice to have deeply nested resources as the corresponding url path helpers become cumbersome. For this example let's try a new method for me: `shallow: true`

```ruby
# config/routes.rb
resources :users do
  resources :wishlists do
    resources :items, shallow: true
  end
end
```
Which generates these routes automatically like so
```ruby
resources :users do
  resources :wishlists do 
    resources :items, only: [:index, :new, :create]
  end
end
resources :items, only: [:show, :edit, :update, :destroy]
```
But in fewer lines of code. Remember kids: fewer lines of code = good!

Now onto the controller. First let's just get items creating
```ruby
# app/controllers/items_controller.rb
class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # I might need a page that shows all of a users current items accross all wishlists
  def index    
    @items = current_user.items.all
  end

  def show
  end

  def edit
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to user_wishlist_path(params[:id]), notice: "Item Created"
    else
      redirect_to :back, notice: "Error"
    end
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :cost, :wishlist_id)
  end

end
```

And then onto the view. Instead of having seperate page views for all of create edit and so on, I want to see a list of all my items on a wishlist show page. First create a link_to show the wishlist
```haml
/ app/views/wishlists/index.html.haml
Here is a list of your Wishlists
%br
- @wishlists.each do |w|
  =w.title
  %br
  = link_to "show", user_wishlist_path(current_user.id, w)
  %br
  = w.description
  %br
  = button_to "Destroy", {:controller => :wishlists, :action => 'destroy', :id => w.id }, :method => :delete, data: { confirm: "Are you sure?" }
```

Now there's two ways we can show the items for each wishlist.  

1. In the view layer we can act on `@wishlist.items` for all our interaction
2. Or down in the controller we can predefine the wishlists items in the show method.

I like the second option as it keeps more logic away from the view layer.

First update the controller
```ruby
# app/controllers/wishlists_controller.rb
  def show
    @items = @wishlist.items
  end
```
Create a show page for the wishlist
```haml
/ app/views/wishlists/show.html.haml
%h2= @wishlist.title
%br
- @items.each do |i|
  = i.name
  %br
%br
= link_to "Back", user_wishlists_path(current_user)
```

I had already created some dummy Item data and going to the show page tells me that my items are showing currectly. Huzzah!

---

#### Items Creating

Lets get the items creating. Because I know I'm eventually going to grab the url from etsy and put it into an input box, I'm only going to create an item with just the name.

First we need to update the routes. This will probably not be necessary as I become a better coder. But, for now, This makes things easier.
```ruby
# config/routes.rb
resources :items, only: :create
```

Then the view side. This should be fairly straightforward by now.
```haml
/ app/views/wishlists/show.html.haml
%h2= @wishlist.title
%br
%ol
  - @items.each do |i|
    %li= i.name
    %br
%br
%br
= form_for @item do |f|
  = f.label :name
  = f.text_field :name
  = f.hidden_field :wishlist_id
  = f.submit
%br
= link_to "Back", user_wishlists_path(current_user)
```
What's happening here is that the `@item` variable already has it's `wishlist_id` defined when its sent up from the controller. By only having a single argument in the `= form_for @item do |f|`, Rails looks for a single `items_path` that doesn't exist cause we defined it as a nested resource earlier. I like it better this way so far because it seems easier than also defining the `current_user.id`, `@wishlist.id`, and the new `@item` in the `form_for` arguments.


Finally the Item controller needs a quick updating.
```ruby
# app/controllers/items_controller.rb
  def create
    # debugger
    @item = Item.new(item_params)
    if @item.save
      redirect_to user_wishlist_path(current_user.id, @item.wishlist_id), notice: "Item Created"
    else
      redirect_to :back, notice: "Error"
    end
  end
```

Hurray! We now have our item creating.

---

#### Items Deleting

Should be, again, straightforward by now.  

Update your routes again
```ruby
# config/routes.rb
resources :items, only: [:create, :destroy]
```

In the view
```haml
/ ap/views/wishlists/show.html.haml
- @items.each do |i|
  %li
    =i.name
    %br
    = button_to "Remove", {:controller => :items, :action => 'destroy', :id => "#{i.id}" }, :method => :delete, data: { confirm: "Are you sure?" }
```
This was odd. The string `:id => "#{i.id}"` was the only way that was working. Surprisingly, a simple integer `i.id` was giving the `user_id` and erroring out. I'll have to figure out why that is later.

Then finally lets put in a destroy method in the controller
```ruby
# app/controllers/items_controller.rb
def destroy
  @item.destroy
  redirect_to :back
end
```

Great! Items are creating and deleting.  

We are now ready to takle API integration for Etsy.

ETSY
---