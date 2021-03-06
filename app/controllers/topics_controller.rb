class TopicsController < ApplicationController
  before_filter :authenticate_user!, :except => [ :show ]
  before_filter :get_discussion_board, :only => [ :new, :create ]

  def new
    @topic = @discussion_board.topics.new :user_id => current_user.id

    authorize! :create, @topic
  end

  def create
    @topic = @discussion_board.topics.new params[:topic]
    @topic.user_id = current_user.id

    authorize! :create, @topic

    if @topic.save
      flash[:notice] = "Topic posted successfully"

      if can?(:update, @discussion_board.club)
        redirect_to discussion_board_editor_path(@discussion_board)
      else
        redirect_to discussion_board_path(@discussion_board)
      end
    else
      render :new
    end

    flash.discard
  end

  def show
    @topic = Topic.find params[:id]

    redirect_to club_sales_page_path(@topic.club) and return unless (user_signed_in? and can?(:read, @topic))

    if request.path != topic_path(@topic)
      redirect_to topic_path(@topic), status: :moved_permanently and return
    end
  end

  private

  def get_discussion_board
    @discussion_board = DiscussionBoard.find params[:discussion_board_id]
  end
end
