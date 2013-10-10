class Post < ActiveRecord::Base
  acts_as_timelineable
end

class User < ActiveRecord::Base
end

class Wall < ActiveRecord::Base
  acts_as_timelineable :public, :private
end
