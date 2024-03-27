class ItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  # Pundit: allow-list approach
  #after_action :verify_authorized, except: :index, unless: :skip_pundit?
  #after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?
  before_action :set_item, only: %i[show edit update destroy]

  def index
    @items = Item.where.not(user: current_user)
    if params[:query].present? && params[:location].present?
      @items = Item.search_by_name_and_description(params[:query])
      @items = @items.near(params[:location], 20)
    elsif params[:query].present?
      @items = Item.search_by_name_and_description(params[:query])
    elsif params[:location].present?
      @items = Item.near(params[:location], 20)
    elsif params[:category].present?
      @items = Item.by_category(params[:category])
    end


  end

  def my_items
    @items = current_user.items
  end

  # Flat.near([40.71, 100.23], 20) # flats within 20 km of a point

  def show
    @reviewed_user = @item.user
    @reviews = Review.where(user_reviewed: @reviewed_user)
    @rating = @reviews.average(:rating).round(2) if @reviews.any?

    @deal = Deal.new
    @offer = Offer.new
    @chatroom = Chatroom.new
    
  end

  def create
    @item = Item.new(item_params)
    @item.user = current_user
    if @item.save
      redirect_to item_path(@item)
    else
      render :new
    end
  end

  def new
    @item = Item.new
  end

  def my_items
    @items = current_user.items
  end

  def edit
  end

  def update
    if @item.update(item_params[:photos] == [""] ? item_params.except(:photos) : item_params)
      redirect_to item_path(@item), status: :see_other
    else
      render show.html.erb, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to myitems_path, status: :see_other, notice: 'Item was successfully destroyed.'
  end



  private

  def item_params
    params.require(:item).permit(:category_id, :name, :description, :condition, :address, photos: [])
  end

  def set_item
    @item = Item.find(params[:id])
  end
end
