class WishlistsController < ActiveRecord::Base
  before_action :authenticate_user!
  before_action :set_wishlist, only:[:show, :edit, :update, :destroy]
  
  def index
    @wishlists = Wishlist.all
  end

  def show
  end

  def edit
  end

  def create
    @new_wishlist = Wishlist.new(wishlist_params)
    if @new_wishlist.save
      redirect_to :index
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
    redirect_to :index
  end


  private

  def set_wishlist
    @wishlist = Wishlist.find(params[:id])
  end

  def wishlist_params
    params.require(:wishlists).permit(:title, :description, :user)

end