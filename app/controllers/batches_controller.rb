class BatchesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def update
    messages = current_user.messages.where(:thread_id => batch_params[:threads])
    messages.update_all(:opened_at => Time.now)
    render(:text => 'OK')
  end

  private

  def batch_params
    params.require(:batch).permit(:threads => [])
  end
end
