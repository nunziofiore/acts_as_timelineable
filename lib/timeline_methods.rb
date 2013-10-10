module ActsAsTimelineable
  # including this module into your Timeline model will give you finders and named scopes
  # useful for working with Timelines.
  # The named scopes are:
  #   in_order: Returns timelines in the order they were created (created_at ASC).
  #   recent: Returns timelines by how recently they were created (created_at DESC).
  #   limit(N): Return no more than N timelines.
  module Timeline

    def self.included(timeline_model)
      timeline_model.extend Finders
      timeline_model.scope :in_order, -> { timeline_model.order('created_at ASC') }
      timeline_model.scope :recent, -> { timeline_model.reorder('created_at DESC') }
    end

    def is_timeline_type?(type)
      type.to_s == role.singularize.to_s
    end

    module Finders
      # Helper class method to lookup all timelines assigned
      # to all timelineable types for a given user.
      def find_timelines_by_user(user, role = "timelines")
        where(["user_id = ? and role = ?", user.id, role]).order("created_at DESC")
      end

      # Helper class method to look up all timelines for 
      # timelineable class name and timelineable id.
      def find_timelines_for_timelineable(timelineable_str, timelineable_id, role = "timelines")
        where(["timelineable_type = ? and timelineable_id = ? and role = ?", timelineable_str, timelineable_id, role]).order("created_at DESC")
      end

      # Helper class method to look up a timelineable object
      # given the timelineable class name and id 
      def find_timelineable(timelineable_str, timelineable_id)
        model = timelineable_str.constantize
        model.respond_to?(:find_timelines_for) ? model.find(timelineable_id) : nil
      end
    end
  end
end
