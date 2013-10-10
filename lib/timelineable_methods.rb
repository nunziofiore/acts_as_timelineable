require 'active_record'

# ActsAsTimelineable
module Juixe
  module Acts #:nodoc:
    module Timelineable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_timelineable(*args)
          timeline_roles = args.to_a.flatten.compact.map(&:to_sym)

          class_attribute :timeline_types
          self.timeline_types = (timeline_roles.blank? ? [:timelines] : timeline_roles)

          options = ((args.blank? or args[0].blank?) ? {} : args[0])

          if !timeline_roles.blank?
            timeline_roles.each do |role|
              has_many "#{role.to_s}_timelines".to_sym,
                -> { where(role: role.to_s) },
                {:class_name => "Timeline",
                  :as => :timelineable,
                  :dependent => :destroy,
                  :before_add => Proc.new { |x, c| c.role = role.to_s }}
            end
            has_many :all_timelines, {:as => :timelineable, :dependent => :destroy, class_name: "Timeline"}
          else
            has_many :timelines, {:as => :timelineable, :dependent => :destroy}
          end

          timeline_types.each do |role|
            method_name = (role == :timelines ? "timelines" : "#{role.to_s}_timelines").to_s
            class_eval %{
              def self.find_#{method_name}_for(obj)
                timelineable = self.base_class.name
                Timeline.find_timelines_for_timelineable(timelineable, obj.id, "#{role.to_s}")
              end

              def self.find_#{method_name}_by_user(user) 
                timelineable = self.base_class.name
                Timeline.where(["user_id = ? and timelineable_type = ? and role = ?", user.id, timelineable, "#{role.to_s}"]).order("created_at DESC")
              end

              def #{method_name}_ordered_by_submitted
                Timeline.find_timelines_for_timelineable(self.class.name, id, "#{role.to_s}").order("created_at")
              end

              def add_#{method_name.singularize}(timeline)
                timeline.role = "#{role.to_s}"
                #{method_name} << timeline
              end
            }
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Juixe::Acts::Timelineable)
