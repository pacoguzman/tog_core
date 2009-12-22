class Admin::AbusesManagerController < Admin::BaseController
  def index  
    @abuses = Abuse.paginate :per_page => Tog::Config['plugins.tog_core.pagination_size'], :page => params[:page], :order => :created_at
  end           

  def show
    @abuse = Abuse.find(params[:id])
  end
  
  def confirm
    @abuse = Abuse.find(params[:id])
    @abuse.confirm!
    if Tog::Plugins.settings(:tog_core, 'abuses.destroy_resource')
      begin
        @abuse.resource.destroy
        flash[:ok] = I18n.t('tog_core.admin.abuses.confirmed_and_destroyed')
      rescue
        flash[:error] = I18n.t('tog_core.admin.abuses.error_confirming')
      end
    end
    redirect_to admin_abuses_index_path
  end
end
