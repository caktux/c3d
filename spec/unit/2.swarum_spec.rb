#!/usr/bin/env ruby
require 'spec_helper'

describe "Publishing Content from c3D to Ethereum" do

  before(:context) do
    set_contract_values
    original_push
    multiples_push
  end

  it "should place blobs into blob_dir." do
    expect( @blobb4 ).to be < ( @blobaf )
  end

  it "should have added torrents to transmission." do
    expect( @torsb4 ).to be < ( @torsaf )
  end

  it "should have placed the recent torrents into the blobs directory." do
    files_exist = @recent_names.map{|n| File.exist?(File.join(ENV['BLOBS_DIR'], n))}.uniq!
    expect( files_exist ).to eq ( [true] )
  end

  it "should publish topics to the blockchain." do
    expect( @topic.topic_id ).to_not eq('0x')
  end

  it "should publish threads to the blockchain." do
    expect( @thread.thread_id ).to_not eq('0x')
  end

  it "should publish a post to the previously made thread." do
    expect( @post.post_id ).to_not eq('0x')
  end

  it "should have placed the topic blob from ethereum into the blobs directory." do
    topic_blob          = @topic.topic_blob[42..-1]
    is_topic_blob_there = @recent_names.include? topic_blob
    expect( is_topic_blob_there ).to be_truthy
  end

  it "should have placed the thread blob from ethereum into the blobs directory." do
    thread_blob          = @thread.thread_blob[42..-1]
    is_thread_blob_there = @recent_names.include? thread_blob
    expect( is_thread_blob_there ).to be_truthy
  end

  it "should have placed the post blob from ethereum into the blobs directory." do
    post_blob          = @post.post_blob[42..-1]
    is_post_blob_there = @recent_names.include? post_blob
    expect( is_post_blob_there ).to be_truthy
  end

  it "should be able to publish multiple blobs to ethereum." do
    expect( @multiple_post_ids.length ).to eq(3)
    expect( @multiple_post_blb.length).to eq(3)
  end

  it "should be able to flag posts." do
    print "\n\nFirst Round of Checks Done. Flagging three Posts.\n\n"
    fp1     = FlagPost.new @multiple_post_ids[0], @flag_bl, @flaglist
    fp2     = FlagPost.new @multiple_post_ids[1], @flag_bl, @flaglist
    fp3     = FlagPost.new @multiple_post_ids[2], @flag_bl, @flaglist
    print "\n"
    expect( fp1.added ).to be_truthy
    expect( fp2.added ).to be_truthy
    expect( fp3.added ).to be_truthy
  end

  it "should be able to remove flagged posts." do
    print "\n\nRemoving a Flag.\n\n"
    rp      = RemoveFlag.new @multiple_post_ids[0], @rm_fl_bl, @flaglist
    print "\n"
    expect( rp.removed ).to be_truthy
  end

  it "should be able to promote flagged posts." do
    print "\n\nPromoting a Flagged Post.\n\n"
    pp1     = PromotePost.new @multiple_post_ids[1], @prom_bl, @promlist
    pp2     = PromotePost.new @multiple_post_ids[2], @prom_bl, @promlist
    print "\n"
    expect( pp1.added ).to be_truthy
    expect( pp2.added ).to be_truthy
  end

  it "should be able to remove promoted posts." do
    print "\n\nRemoving a Promoted Post.\n\n"
    rp      = RemovePromoted.new @multiple_post_ids[1], @rm_pr_bl, @promlist
    print "\n"
    expect( rp.removed ).to be_truthy
  end

  it "should be able to blacklist promoted posts." do
    print "\n\nBlacklisting a Promoted Post.\n\n"
    bp      = BlacklistPost.new @multiple_post_ids[2], @prom_bl, @blacklst
    print "\n"
    expect( bp.added ).to be_truthy
  end

  it "should be able to move threads between topics." do
    print "\n\nMoving a Thread between Topics.\n\n"
    mv      = MoveThread.new @thread.thread_id, get_another_topic, @m_thr_bl
    print "\n"
    expect( mv.moved ).to be_truthy
    expect( mv.topic_id ).to_not eq( @topic.topic_id )
  end

  it "should be able to up vote posts." do
    print "\n\nSubmitting an Upvote.\n\n"
    uvp     = VotePost.new @post.post_id, 'upvote', @vote_bl
    print "\n"
    # for now I'm not sure which position to check.
    expect( false ).to be_truthy
  end

  it "should be able to down vote posts." do
    print "\n\nSubmitting a Downvote.\n\n"
    dvp     = VotePost.new @post.post_id, 'downvote', @vote_bl
    print "\n"
    # for now I'm not sure which position to check.
    expect( false ).to be_truthy
  end
end

def original_push
  before_orig_push_helper
  @topic    = CreateTopic.new  make_test_file, @c_top_bl, @swarum
  @thread   = CreateThread.new make_test_file, @c_thr_bl, @topic.topic_id
  p @thread.thread_id
  @post     = PostToThread.new make_test_file, @c_pos_bl, @thread.thread_id
  after_orig_push_helper
end

def multiples_push
  @multiple_post_ids = []
  @multiple_post_blb = []
  3.times do
    post               = PostToThread.new make_test_file, @c_pos_bl, @thread.thread_id
    @multiple_post_ids << post.post_id
    @multiple_post_blb << post.post_blob[42..-1]
  end
  print "\nPush Done. Performing Tests.\n\n"
end

def set_contract_values
  @doug     = get_latest_doug
  @swarum   = get_dougs_storage 'swarum'
  @flaglist = get_dougs_storage 'flaggedlist'
  @promlist = get_dougs_storage 'promotedlist'
  @blacklst = get_dougs_storage 'blacklist'
  @c_top_bl = get_dougs_storage 'BLWCTopic'
  @c_thr_bl = get_dougs_storage 'BLWCThread'
  @c_pos_bl = get_dougs_storage 'BLWPostTT'
  @m_thr_bl = get_dougs_storage 'BLWMoveThread'
  @flag_bl  = get_dougs_storage 'BLWFlagPost'
  @rm_fl_bl = get_dougs_storage 'BLWRemoveFlag'
  @prom_bl  = get_dougs_storage 'BLWPromotePost'
  @rm_pr_bl = get_dougs_storage 'BLWRemovePromoted'
  @black_bl = get_dougs_storage 'BLWBlacklist'
  @vote_bl  = get_dougs_storage 'BLWVoteUpDown'
end

def get_latest_doug
  log = File.join(ENV['HOME'], '.epm', 'deployed-log.csv')
  log = File.read log
  doug = log.split("\n").map{|l| l.split(',')}.select{|l| l[0] == ("Doug" || "DOUG" || "doug")}[-1][-1]
  return doug
end

def get_another_topic
  first_topic = $eth.get_storage_at @swarum, '0x19'
  if first_topic == @topic.topic_id
    next_topic = "0x" + ((first_topic.hex + 0x1).to_s(16))
    return $eth.get_storage_at @swarum, next_topic
  else
    return first_topic
  end
end

def get_dougs_storage position
  unless position[0..1] == '0x'
    position = EPM::HexData.construct_data [position]
  end
  return $eth.get_storage_at @doug, position
end

def make_test_file
  test_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'tmp')
  return File.read(test_file) + "\n#{Time.now}\n#{rand(100000)}"
end

def before_orig_push_helper
  @blobb4 = Dir.glob(File.join(ENV['BLOBS_DIR'], '*')).count
  @torsb4 = $puller.all.count
end

def after_orig_push_helper
  @blobaf       = Dir.glob(File.join(ENV['BLOBS_DIR'], '*')).count
  @torsaf       = $puller.all.count
  @recent_names = $puller.all.map{|e| e['id']}.sort![-3..-1].map{|e| $puller.find(e)['name']}
end

def remove_flag
  print "\nFirst Round of Checks Done. Flagging a Post.\n\n"
  post_id = @multiple_post_ids[0]
  fp = FlagPost.new post_id, @flag_bl, @flaglist
  return fp.added
end

def promote_post
  print "\nFlagged the Post. Now Promoting it for review.\n\n"
  post_id = @multiple_post_ids[0]
  fp = FlagPost.new post_id, @flag_bl, @flaglist
  return fp.added
end