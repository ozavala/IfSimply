class Post < ActiveRecord::Base
  attr_accessible :content, :user_id

  default_scope order('created_at ASC')

  validates :content, :presence => { :message => "for post can't be blank" }

  belongs_to :topic

  def poster
    begin
      User.try(:find, user_id)
    rescue
      'unknown'
    end
  end
end