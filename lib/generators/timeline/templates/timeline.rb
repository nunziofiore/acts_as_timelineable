class Timeline < ActiveRecord::Base

  include ActsAsTimelineable::Timeline

  belongs_to :timelineable, :polymorphic => true

  default_scope -> { order('created_at ASC') }

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of timelines.
  #acts_as_voteable

  # NOTE: Timelines belong to a user
  belongs_to :user
end
