class DealsController < ApplicationController
  before_action :set_deal, only: %i[show cancel complete]

  def index
    @offered_offers = current_user.offered_offers.where(status: 'pending')
    @received_offers = current_user.received_offers.where(status: 'pending')
    @deals = current_user.deals
    @deal = Deal.new
    @review = Review.new
    @chatroom = Chatroom.new
    @accepted_deals = filter_deals('accepted')
    @completed_deals = filter_deals('completed')
    @canceled_deals = filter_deals('canceled')
    @finished_deals = @completed_deals + @canceled_deals
  end

  def show
    @reviewed_user = @deal.user_offerer == current_user ? @deal.user_requested : @deal.user_offerer
    @reviews = Review.where(user_reviewed: @reviewed_user)
    @rating = @reviews.average(:rating).round(2) if @reviews.any?
    @review = Review.new
    @chatroom = Chatroom.new
    authorize @deal
  end

  def create
    @deal = Deal.new(deal_params)
    @deal.status = "accepted"
    if @deal.save
      Offer.find(@deal.offer_id).update(status: "accepted")
      redirect_to deals_path, notice: "Trueque aceptado"
    else
      render 'deals/index'
    end
  end

  def cancel
    @deal.status = "canceled"
    @deal.save
    redirect_to deals_path
  end

  def complete
    @deal.status = "completed"
    @deal.save
    # Hide items after a deal is completed
    @items = [@deal.offered_item, @deal.requested_item]
    @items.each do |item|
      if item.category.name != "Servicios"
        item.update(hidden: true)
        # Cancel offers related to an item that's hidden after a deal is completed
        offers = Offer.where(offered_item: item)
        offers.update_all(status: "canceled") if offers.any?

        requests = Offer.where(requested_item: item)
        requests.update_all(status: "canceled") if requests.any?

        # Cancel deals related to an item that's hidden after a deal is completed
        deals = Deal.joins(:offer).where.not(status: 'completed').where("offers.offered_item_id = ? OR offers.requested_item_id = ?", item.id, item.id)
        deals.update_all(status: "canceled") if deals.any?
      end
    end
    redirect_to deals_path
  end


  private

  def deal_params
  params.require(:deal).permit(:offer_id)
  end

  def set_deal
    @deal = Deal.find(params[:id])
  end

  def filter_deals(status)
    @deals.select { |deal| deal.status == status }
  end

end
