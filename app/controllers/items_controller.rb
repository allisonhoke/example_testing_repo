class ItemsController < ApplicationController
  def index
    @media = readable_media_type
    @all_items = Item.order(rank: :desc).where(kind: @media)
    # @media = Item::ALBUM_MEDIA

  end

  def show
    @item = Item.find_by(id: params[:id].to_i)

    if @item == nil # if the item does not exist
      flash[:notice] = EXIST_ERROR
      redirect_to items_path(raw_media_type)
    elsif @item.kind != readable_media_type
      flash[:notice] = type_error(readable_media_type)
      redirect_to items_path(raw_media_type)
    end
  end

  def new
    @item = Item.new
    @author_text = Item::AUTHORS[readable_media_type]
  end

  def create
    @item = Item.new(post_params(params))
    @item.rank = 0
    @item.kind = readable_media_type
    if @item.save
      # success
      redirect_to items_path(raw_media_type)
    else
      render :new
    end
  end

  def edit
    @item = Item.find_by(id: params[:id])
    if @item == nil # if the item does not exist
      flash[:notice] = EXIST_ERROR
      redirect_to items_path(raw_media_type)
    end

    @author_text = Item::AUTHORS[readable_media_type]
  end

  def update
    @item = Item.find_by(id: params[:id])
    if @item == nil # if the item does not exist
      redirect_to :index, flash: {notice: EXIST_ERROR }
    end

    if @item.update_attributes(post_params(params))
      redirect_to item_path(raw_media_type, @item.id), flash: {notice: "Item saved."}
    else
      redirect_to edit_item_path(raw_media_type, @item.id), flash: {notice: "Item could not be saved."}
    end
  end

  def destroy
    @item = Item.find_by(id: params[:id].to_i)
    if @item == nil # if the item does not exist
      flash[:notice] = EXIST_ERROR
      redirect_to action: "index"
    elsif @item.destroy
      flash[:notice] = DELETE_MSG
      redirect_to action: "index", status: 303
    else
      flash[:notice] = "Unable to delete the movie"
      redirect_to action: "index", status: 303
    end
  end

  def upvote
    @item = Item.find_by(id: params[:id].to_i)
    if @item == nil # if the item does not exist
      flash[:notice] = EXIST_ERROR
      redirect_to action: "index"
    else
      @item.upvote
      if request.referer
        redirect_to request.referer
      else
        redirect_to action: "index"
      end
    end
  end

  private

  def readable_media_type
    @readable_media ||= params[:media_type].capitalize.singularize
  end

  def raw_media_type
    @media ||= params[:media_type].downcase.pluralize
  end

  def post_params(params)
    params.require(:item).permit(:name, :author, :description)
  end
end
