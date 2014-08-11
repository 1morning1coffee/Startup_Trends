class StartupsController < ApplicationController

	before_action :set_startup, only: [ :show, :edit, :update, :destroy ]

	def show
		@startup.views = @startup.views + 1
		@startup.save
	end

	def new
		@startup = Startup.unscoped.new
	end

	def create

		@startup = Startup.unscoped.new(startup_params)

		@startup.smart_add_url_protocol

		unless @startup.website_thumbnail.exists? then create_website_thumbnail(@startup) end

			if @startup.save
				flash[:success] = 'Startup was successfuly created. Please wait until administrator accept your request.'
				redirect_to @startup
			else
				@startup.destroy
				flash.now[:error] = @startup.errors.full_messages
				render action: :new
			end
	end
	

	def index
		@startups = Startup.order("created_at DESC").where(visible: true).paginate(:page => params[:page], :per_page => 5)
	end

	
private

	def set_startup
		@startup = Startup.all.find(params[:id])
	end

	def startup_params
		params.require(:startup).permit(:name, :description, :short_description, :website_url, :category_id)
	end

	def create_website_thumbnail(startup)
		kit = IMGKit.new(startup.website_url.to_s)
		img = kit.to_img(:jpg)
		file = Tempfile.new(["thumbnail_#{startup.name}", 'jpg'], 'tmp', :encoding => 'ascii-8bit')
		file.write(img)
		file.flush
		startup.website_thumbnail = file
		file.unlink

		rescue
			false
	end

end