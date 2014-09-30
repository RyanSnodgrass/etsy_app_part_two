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