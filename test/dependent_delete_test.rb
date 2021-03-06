require "#{File.dirname(__FILE__)}/test_helper"

class DependentDeleteTest < Test::Unit::TestCase

  def setup
    @fred   = Parent.create!(:name => "fred")
  end

  def teardown
    Parent.delete_all
    DeleteOne.delete_all
    SoftDeleteOne.delete_all
  end

  def test_destroy_has_one_soft_delete_one
    @fred.soft_delete_one = pebbles = SoftDeleteOne.new(:name => "pebbles")
    assert_equal pebbles, @fred.reload.soft_delete_one
    assert_equal @fred, pebbles.parent
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_equal 0, SoftDeleteOne.where(:name => "pebbles", :parent_id => @fred.id).count
    assert_equal 1, SoftDeleteOne.where(:name => "pebbles").count
  end

  def test_destroy_has_one_delete_children
    @fred.delete_one = pebbles = DeleteOne.new(:name => "pebbles")
    assert_equal pebbles, @fred.reload.delete_one
    @fred.destroy
    assert_equal true, @fred.deleted?
    assert_equal 0, DeleteOne.where(:name => "pebbles", :parent_id => @fred.id).count
    assert_equal 1, DeleteOne.where(:name => "pebbles").count
  end

  def test_destroy_bang_has_one_soft_delete_one
    @fred.soft_delete_one = pebbles = SoftDeleteOne.new(:name => "pebbles")
    assert_equal pebbles, @fred.reload.soft_delete_one
    assert_equal @fred, pebbles.parent
    @fred.hard_destroy
    assert_nil Parent.find_by_id(@fred.id)
    assert_equal 0, SoftDeleteOne.where(:name => "pebbles", :parent_id => @fred.id).count
    assert_equal 1, SoftDeleteOne.where(:name => "pebbles").count
  end

  def test_destroy_bang_has_one_delete_one
    @fred.delete_one = pebbles = DeleteOne.new(:name => "pebbles")
    assert_equal pebbles, @fred.reload.delete_one
    @fred.hard_destroy
    assert_nil Parent.find_by_id(@fred.id)
    assert_equal 0, DeleteOne.where(:name => "pebbles", :parent_id => @fred.id).count
    assert_equal 1, DeleteOne.where(:name => "pebbles").count
  end

  # revive

  def test_revive_does_not_delete_all_has_one_soft_delete_one
    @fred.destroy
    @fred.soft_delete_one = bambam = SoftDeleteOne.new(:name => "bambam")
    assert_equal bambam, @fred.reload.soft_delete_one
    @fred.revive
    assert_equal bambam, @fred.reload.soft_delete_one
  end

  def test_revive_does_not_delete_all_has_one_delete_one
    @fred.destroy
    @fred.delete_one = bambam = DeleteOne.new(:name => "bambam")
    assert_equal bambam, @fred.reload.delete_one
    @fred.revive
    assert_equal bambam, @fred.reload.delete_one
  end

end