require 'spec_helper'

describe Lesson do
  it { should belong_to :course }

  # file_attachment via PaperClip
  it { should have_attached_file(:file_attachment) }
  it { should validate_attachment_content_type(:file_attachment).
                allowing('audio/mp4', 'audio/mpeg', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                         'application/vnd.openxmlformats-officedocument.spreadsheetml.template', 'application/vnd.openxmlformats-officedocument.presentationml.template',
                         'application/vnd.openxmlformats-officedocument.presentationml.slideshow', 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
                         'application/vnd.openxmlformats-officedocument.presentationml.slide', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                         'application/vnd.openxmlformats-officedocument.wordprocessingml.template', 'application/vnd.ms-excel.addin.macroEnabled.12',
                         'application/vnd.ms-excel.sheet.binary.macroEnabled.12', 'application/pdf', 'text/plain', 'text/rtf')
     }
  it { should validate_attachment_size(:file_attachment).in(0..10000.kilobytes) }

  it "can be instantiated" do
    Lesson.new.should be_an_instance_of(Lesson)
  end

  describe "valid?" do
    before :each do
      FakeWeb.clean_registry
      FakeWeb.register_uri(:head, "http://www.ifsimply.com/", :body => "", :status => [ "200", "OK" ])
    end

    # title
    it "returns false when no title is specified" do
      FactoryGirl.build(:lesson, :title => "").should_not be_valid
    end

    # background
    it "returns false when no background is specified" do
      FactoryGirl.build(:lesson, :background => "").should_not be_valid
    end

    # video
    describe "for video" do
      it "returns false when the URL is malformed" do
        FactoryGirl.build(:lesson, :video => "bogus url").should_not be_valid
      end

      it "returns true when the URL is reachable" do
        FactoryGirl.build(:lesson, :video => "http://www.ifsimply.com/").should be_valid
      end

      it "returns true when URL is blank/not specified" do
        FactoryGirl.build(:lesson, :video => "").should be_valid
      end
    end

    # free
    describe "for free" do
      it "returns false when no free is specified" do
        FactoryGirl.build(:lesson, :free => "").should_not be_valid
      end

      it "returns true when free is a string of a boolean" do
        FactoryGirl.build(:lesson, :free => true).should be_valid
      end
    end
  end

  describe "club" do
    let(:course) { FactoryGirl.create :course }

    it "returns the corresponding courses' club" do
      FactoryGirl.create(:lesson, :course => course).club.should == course.club
    end
  end

  describe "user" do
    let(:club)   { FactoryGirl.create :club }
    let(:course) { FactoryGirl.create :course, :club => club }

    it "returns the corresponding course's user" do
      FactoryGirl.create(:lesson, :course_id => course.id).user.should == course.user
    end
  end

  describe "assign_defaults" do
    let(:course) { FactoryGirl.create :course }

    before :each do
      @lesson = Lesson.new
      @lesson.course_id = course.id
      @lesson.assign_defaults
      @lesson.save
    end

    it "assigns the correct default title" do
      @lesson.title.should == "Lesson 1 - #{Settings.lessons[:default_title]}"
    end

    it "assigns the correct default background" do
      @lesson.background.should == Settings.lessons[:default_background]
    end

    it "assigns the correct default free boolean" do
      @lesson.free.should == Settings.lessons[:default_free]
    end
  end
end
