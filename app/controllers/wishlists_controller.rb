class WishlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist, only:[:show, :edit, :update, :destroy]
  
  def index
    @wishlists = current_user.wishlists.all
  end

  def show
    @items = @wishlist.items
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