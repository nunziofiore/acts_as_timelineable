require 'test/unit'
require 'logger'
require 'pry'
require File.expand_path(File.dirname(__FILE__) + '/../rails/init')

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class ActsAsTimelineableTest < Test::Unit::TestCase

  def setup_timelines
    require File.expand_path(File.dirname(__FILE__) + '/../lib/generators/timeline/templates/create_timelines') 
    CreateTimelines.up
    load(File.expand_path(File.dirname(__FILE__) + '/../lib/generators/timeline/templates/timeline.rb'))
  end

  def setup_test_models
    load(File.expand_path(File.dirname(__FILE__) + '/schema.rb'))
    load(File.expand_path(File.dirname(__FILE__) + '/models.rb'))
  end

  def setup
    setup_timelines
    setup_test_models
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def test_create_timeline
    post = Post.create(:text => "Awesome post !")
    assert_not_nil post.timelines.create(:title => "timeline.", :timeline => "This is the a timeline.").id

    wall = Wall.create(:name => "My Wall")
    assert_not_nil wall.public_timelines.create(:title => "timeline.", :timeline => "This is the a timeline.").id
    assert_not_nil wall.private_timelines.create(:title => "timeline.", :timeline => "This is the a timeline.").id
    assert_raise NoMethodError do
      wall.timelines.create(:title => "Timeline", :title => "Title")
    end
  end

  def test_fetch_timelines
    post = Post.create(:text => "Awesome post !")
    post.timelines.create(:title => "First timeline.", :timeline => "This is the first timeline.")
    timelineable = Post.find(1)
    assert_equal 1, timelineable.timelines.length
    assert_equal "First timeline.", timelineable.timelines.first.title
    assert_equal "This is the first timeline.", timelineable.timelines.first.timeline

    wall = Wall.create(:name => "wall")
    private_timeline = wall.private_timelines.create(:title => "wall private timeline", :timeline => "Yipiyayeah !")
    assert_equal [private_timeline], wall.private_timelines
    public_timeline = wall.public_timelines.create(:title => "wall public timeline", :timeline => "Yipiyayeah !")
    assert_equal [public_timeline], wall.public_timelines
  end

  def test_find_timelines_by_user
    user = User.create(:name => "Mike")
    user2 = User.create(:name => "Fake") 
    post = Post.create(:text => "Awesome post !")
    timeline = post.timelines.create(:title => "First timeline.", :timeline => "This is the first timeline.", :user => user)
    assert_equal true, Post.find_timelines_by_user(user).include?(timeline)
    assert_equal false, Post.find_timelines_by_user(user2).include?(timeline) 
  end

  def test_find_timelines_for_timelineable
    post = Post.create(:text => "Awesome post !")
    timeline = post.timelines.create(:title => "First timeline.", :timeline => "This is the first timeline.")
    assert_equal [timeline], Timeline.find_timelines_for_timelineable(post.class.name, post.id)
  end

  def test_find_timelineable
    post = Post.create(:text => "Awesome post !")
    timeline = post.timelines.create(:title => "First timeline.", :timeline => "This is the first timeline.")
    assert_equal post, Timeline.find_timelineable(post.class.name, post.id) 
  end

  def test_find_timelines_for
    post = Post.create(:text => "Awesome post !")
    timeline = post.timelines.create(:title => "First timeline.", :timeline => "This is the first timeline.")
    assert_equal [timeline], Post.find_timelines_for(post)

    wall = Wall.create(:name => "wall")
    private_timeline = wall.private_timelines.create(:title => "wall private timeline", :timeline => "Yipiyayeah !")
    assert_equal [private_timeline], Wall.find_private_timelines_for(wall)

    public_timeline = wall.public_timelines.create(:title => "wall public timeline", :timeline => "Yipiyayeah !")
    assert_equal [public_timeline], Wall.find_public_timelines_for(wall)
  end

  def test_find_public_private_timelines_by_user
    user = User.create(:name => "Mike")
    post = Post.create(:text => "Awesome post !")
    timeline = post.timelines.create(:title => "First timeline.", :timeline => "This is the first timeline.", :user => user)
    assert_equal [timeline], Post.find_timelines_by_user(user)

    wall = Wall.create(:name => "wall")
    private_timeline = wall.private_timelines.create(:title => "wall private timeline", :timeline => "Yipiyayeah !", :user => user)
    assert_equal [private_timeline], Wall.find_private_timelines_by_user(user)

    public_timeline = wall.public_timelines.create(:title => "wall public timeline", :timeline => "Yipiyayeah !", :user => user)
    assert_equal [public_timeline], Wall.find_public_timelines_by_user(user)
  end

  def test_timelines_public_private_ordered_by_submitted
    post = Post.create(:text => "Awesome post !")
    timeline = post.timelines.create(:title => "First timeline.", :timeline => "This is the first timeline.")
    timeline2 = post.timelines.create(:title => "Second timeline.", :timeline => "This is the second timeline.")
    assert_equal [timeline, timeline2], post.timelines_ordered_by_submitted

    wall = Wall.create(:name => "wall")
    private_timeline = wall.private_timelines.create(:title => "wall private timeline", :timeline => "Yipiyayeah !")
    private_timeline2 = wall.private_timelines.create(:title => "wall private timeline", :timeline => "Yipiyayeah !")
    assert_equal [private_timeline, private_timeline2], wall.private_timelines_ordered_by_submitted

    public_timeline = wall.public_timelines.create(:title => "wall public timeline", :timeline => "Yipiyayeah !")
    public_timeline2 = wall.public_timelines.create(:title => "wall public timeline", :timeline => "Yipiyayeah !")
    assert_equal [public_timeline, public_timeline2], wall.public_timelines_ordered_by_submitted
  end

  def test_timelines_ordered_by_submitted
    post = Post.create(:text => "Awesome post !")
    timeline = post.timelines.create(:title => "First timeline.", :timeline => "This is the first timeline.")
    timeline2 = post.timelines.create(:title => "Second timeline.", :timeline => "This is the second timeline.")
    assert_equal [timeline2, timeline], post.timelines.recent

    wall = Wall.create(:name => "wall")
    private_timeline = wall.private_timelines.create(:title => "wall private timeline", :timeline => "Yipiyayeah !")
    private_timeline2 = wall.private_timelines.create(:title => "wall private timeline", :timeline => "Yipiyayeah !")
    assert_equal [private_timeline2, private_timeline], wall.private_timelines.recent

    public_timeline = wall.public_timelines.create(:title => "wall public timeline", :timeline => "Yipiyayeah !")
    public_timeline2 = wall.public_timelines.create(:title => "wall public timeline", :timeline => "Yipiyayeah !")
    assert_equal [public_timeline2, public_timeline], wall.public_timelines.recent
  end

  def test_add_timeline
    post = Post.create(:text => "Awesome post !")
    timeline = Timeline.new(:title => "First Timeline", :timeline => 'Super timeline')
    post.add_timeline(timeline)
    assert_equal [timeline], post.timelines

    wall = Wall.create(:name => "wall")
    private_timeline = Timeline.new(:title => "First Timeline", :timeline => 'Super timeline')
    wall.add_private_timeline(private_timeline)
    assert_equal [private_timeline], wall.private_timelines

    public_timeline = Timeline.new(:title => "First Timeline", :timeline => 'Super timeline')
    wall.add_public_timeline(public_timeline)
    assert_equal [public_timeline], wall.public_timelines
  end

  def test_is_timeline_type
    post = Post.create(:text => "Awesome post !")
    timeline = Timeline.new(:title => "First Timeline", :timeline => 'Super timeline')
    post.add_timeline(timeline)
    assert_equal true, timeline.is_timeline_type?(:timeline)

    wall = Wall.create(:name => "wall")
    private_timeline = Timeline.new(:title => "First Timeline", :timeline => 'Super timeline')
    wall.add_private_timeline(private_timeline)
    assert_equal true, private_timeline.is_timeline_type?(:private)

    public_timeline = Timeline.new(:title => "First Timeline", :timeline => 'Super timeline')
    wall.add_public_timeline(public_timeline)
    assert_equal true, public_timeline.is_timeline_type?(:public)
    assert_equal false, public_timeline.is_timeline_type?(:timeline)
  end

end
