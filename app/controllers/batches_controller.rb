class BatchesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def update
    messages = current_user.messages.where(:thread_id => batch_params[:threads])
    messages.update_all(:opened_at => Time.now)
    render(:text => 'OK')
  end

  def destroy
    messages = current_user.messages.where(:thread_id => batch_params[:threads])
    current_user.archive_messages!(messages)
    render(:text => 'Message(s) successfully deleted.')

  rescue => ex
    puts "Error deleting message(s): #{ex.inspect}"
    render(:text => ex.message, :status => 403)
  end

  private

  def batch_params
    params.require(:batch).permit(:threads => [])
  end
end
