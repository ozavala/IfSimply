require 'spec_helper'

describe "lessons/_list.html.erb" do
  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:video_src) { "http://www.google.com/" }
  let!(:user)      { FactoryGirl.create :user }
  let!(:club)      { user.clubs.first }
  let!(:course)    { FactoryGirl.create :course, :club => club }

  describe "course lessons list" do
    describe "for a club owner" do
      let!(:lesson) { FactoryGirl.create :lesson, :course => course, :video => video_src, :free => false }

      before :each do
        user.confirm!
        login_as user, :scope => :user

        visit course_path(course)
      end

      it "displays the lesson video" do
        within ".lesson-video .video-iframe" do
          page.should have_selector("iframe")
        end
      end
    end

    describe "for a basic subscriber" do
      let!(:course)          { FactoryGirl.create :course }
      let!(:subscribed_user) { FactoryGirl.create :user }
      let!(:subscription)    { FactoryGirl.create :subscription, :user => subscribed_user, :club => course.club, :level => 'basic' }

      before :each do
        subscribed_user.confirm!
        login_as subscribed_user, :scope => :user
      end

      describe "for a free lesson" do
        let!(:free_lesson) { FactoryGirl.create :lesson, :course => course, :video => video_src, :free => true }

        before :each do
          visit course_path(course)
        end

        it "displays the lesson video" do
          within ".lesson-video .video-iframe" do
            page.should have_selector("iframe")
          end
        end
      end

      describe "for a paid lesson" do
        let!(:paid_lesson) { FactoryGirl.create :lesson, :course => course, :video => video_src, :free => false }

        before :each do
          visit course_path(course)
        end

        it "does not display the lesson video" do
          within ".lesson-video .video-iframe" do
            page.should_not have_selector("iframe")
          end
        end

        it "displays a link to sales page" do
          within ".lesson-video .video-iframe" do
            page.should have_selector("a")
          end
        end

        it "displays a 'Pro' logo" do
          within ".lesson-video .video-iframe a" do
            page.should have_selector("img")
          end
        end
      end
    end

    describe "for a pro subscriber" do
      let!(:course)          { FactoryGirl.create :course }
      let!(:subscribed_user) { FactoryGirl.create :user }
      let!(:subscription)    { FactoryGirl.create :subscription, :user => subscribed_user, :club => course.club, :level => 'pro', :pro_active => true }

      before :each do
        subscribed_user.confirm!
        login_as subscribed_user, :scope => :user
      end

      describe "for a free lesson" do
        let!(:free_lesson) { FactoryGirl.create :lesson, :course => course, :video => video_src, :free => true }

        before :each do
          visit course_path(course)
        end

        it "displays the lesson video" do
          within ".lesson-video .video-iframe" do
            page.should have_selector("iframe")
          end
        end
      end

      describe "for a paid lesson" do
        let!(:paid_lesson) { FactoryGirl.create :lesson, :course => course, :video => video_src, :free => false }

        before :each do
          visit course_path(course)
        end

        it "displays the lesson video" do
          within ".lesson-video .video-iframe" do
            page.should have_selector("iframe")
          end
        end
      end
    end
  end
end
