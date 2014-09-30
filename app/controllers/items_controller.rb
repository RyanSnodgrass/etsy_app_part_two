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
    # @item = 
  end

  def create
    # debugger
    @item = Item.new(item_params)
    if @item.save
      redirect_to user_wishlist_path(current_user.id, @item.wishlist_id), notice: "Item Created"
    else
      redirect_to :back, notice: "Error"
    end
  end

  def destroy
    @item.destroy
    redirect_to :back, notice: "Item Removed"
  end

    # user_wishlist_path(current_user.id, @item.wishlist_id), notice: "Item Created"

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :cost, :wishlist_id)
  end

end