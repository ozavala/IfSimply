require 'spec_helper'

describe LessonsController do
  let(:user) { FactoryGirl.create :user }

  describe "POST 'create'" do
    let(:course) { FactoryGirl.create :course, :club_id => user.clubs.first.id }

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:users]
      sign_in user

      post 'create', :course_id => course.id
    end

    it "returns http redirect" do
      response.should be_redirect
    end

    it "should redirect to the edit course path" do
      response.should redirect_to(course_editor_path(course))
    end

    it "returns the course" do
      assigns(:course).should == course
    end

    it "returns the lesson belonging to the course" do
      assigns(:lesson).should_not be_nil
      assigns(:lesson).course.should == assigns(:course)
    end

    it "assigns the default initial title" do
      assigns(:lesson).title.should == "Lesson 1 - #{Settings.lessons[:default_initial_title]}"
    end

    it "assigns the default initial background" do
      assigns(:lesson).background.should == Settings.lessons[:default_initial_background]
    end
  end

  describe "PUT 'update'" do
    let(:course) { FactoryGirl.create :course, :club_id => user.clubs.first.id }
    let(:lesson) { FactoryGirl.create :lesson, :course_id => course.id }

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:users]
      sign_in user
    end

    describe "for valid attributes" do
      before :each do
        put 'update', :course_id => course.id, :id => lesson.id, :lesson => { :free => true }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.free.should == true
      end
    end

    describe "for invalid attributes" do
      before :each do
        @old_free = lesson.free
        put 'update', :course_id => course.id, :id => lesson.id, :lesson => { :free => "" }
      end

      it "returns http unprocessable" do
        response.response_code.should == 422
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "does not update the attributes" do
        lesson.reload
        lesson.free.should == @old_free
      end
    end
  end

  describe "PUT 'update_file_attachment'" do
    let(:course) { FactoryGirl.create :course, :club_id => user.clubs.first.id }
    let(:lesson) { FactoryGirl.create :lesson, :course_id => course.id }

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:users]
      sign_in user
    end

    describe "for a non-accepted MIME type" do
      before :each do
        @file = fixture_file_upload('/test.txt', 'text/bogus')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should be_blank
      end

      it "assigns a flash error" do
        flash[:error].should_not be_blank
      end
    end

    describe "for a normal text document" do
      before :each do
        @file = fixture_file_upload('/test.txt', 'text/plain')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should_not be_blank
      end
    end

    describe "for an RTF text document" do
      before :each do
        @file = fixture_file_upload('/test.rtf', 'text/richtext')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should_not be_blank
      end
    end

    describe "for a PDF document" do
      before :each do
        @file = fixture_file_upload('/test.pdf', 'application/pdf')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should_not be_blank
      end
    end

    describe "for a PowerPoint document (old)" do
      before :each do
        @file = fixture_file_upload('/test.ppt', 'application/vnd.ms-powerpoint')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should_not be_blank
      end
    end

    describe "for a PowerPoint document (new)" do
      before :each do
        @file = fixture_file_upload('/test.pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should_not be_blank
      end
    end

    describe "for a Word document (old)" do
      before :each do
        @file = fixture_file_upload('/test.doc', 'application/msword')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should_not be_blank
      end
    end

    describe "for a Word document (new)" do
      before :each do
        @file = fixture_file_upload('/test.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should_not be_blank
      end
    end

    describe "for an Excel document (old)" do
      before :each do
        @file = fixture_file_upload('/test.xls', 'application/vnd.ms-excel')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should_not be_blank
      end
    end

    describe "for an Excel document (new)" do
      before :each do
        @file = fixture_file_upload('/test.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should_not be_blank
      end
    end

    describe "for a mp3 audio file" do
      before :each do
        @file = fixture_file_upload('/test.mp3', 'audio/mpeg')

        put 'update_file_attachment', :format => :js, :course_id => course.id, :lesson_id => lesson.id, :lesson => { :file_attachment => @file }
      end

      it "returns http success" do
        response.should be_success
      end

      it "returns the course" do
        assigns(:course).should == course
      end

      it "returns the lesson" do
        assigns(:lesson).should == lesson
      end

      it "assigns the new attributes" do
        lesson.reload
        lesson.file_attachment.should_not be_blank
      end
    end
  end

  describe "DELETE 'destroy'" do
    let!(:course) { FactoryGirl.create :course, :club_id => user.clubs.first.id }

    describe "for a signed in User" do
      before :each do
        @request.env["devise.mapping"] = Devise.mappings[:users]
        sign_in user
      end

      describe "who owns the Lesson" do
        let!(:owned_lesson) { FactoryGirl.create :lesson, :course_id => course.id }

        before :each do
          Lesson.any_instance.should_receive(:destroy)

          delete 'destroy', :id => owned_lesson.id
        end

        it "redirects to the Course edit view" do
          response.should redirect_to(course_editor_path(course))
        end

        it "returns the course" do
          assigns(:course).should == owned_lesson.course
        end
      end

      describe "who does not own the Lesson" do
        let!(:non_owned_lesson) { FactoryGirl.create :lesson }

        before :each do
          Lesson.any_instance.should_not_receive(:destroy)

          delete 'destroy', :id => non_owned_lesson.id
        end

        it "returns 403 unauthorized forbidden code" do
          response.response_code.should == 403
        end

        it "returns the course" do
          assigns(:course).should == non_owned_lesson.course
        end
      end
    end

    describe "for a non signed-in user" do
      let!(:lesson) { FactoryGirl.create :lesson }

      before :each do
        Lesson.any_instance.should_not_receive(:destroy)

        delete 'destroy', :id => course.id
      end

      it "redirects to the sign-in page" do
        response.should redirect_to(new_user_session_path)
      end
    end
  end
end
