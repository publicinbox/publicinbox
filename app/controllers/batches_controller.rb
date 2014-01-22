class BatchesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def update
    messages = current_user.messages.where(:unique_token => batch_params[:messages])
    messages.update_all(:opened_at => Time.now)
    render(:text => 'OK')
  end

  def delete
    messages = current_user.messages.where(:unique_token => delete_params[:messages].split(','))
    messages.update_all(:archived_at => Time.now)
    render(:text => 'OK')
  end

  private

  def batch_params
    params.require(:batch).permit(:messages)
  end

  def delete_params
    params.permit(:messages)
  end
end
