class OperationsController < ApplicationController
  load_resource
  authorize_resource

  respond_to :js

  def index
    respond_with @operations
  end

  def destroy
    @operations = Operation.accessible_by(@current_ability, :destroy)
    if @operation.running?
      @operation.abort!
    elsif @operation.complete? || @operation.failed? || (@operation.pending? && @operation.scheduled_at > Time.now)
      @operation.destroy
    end
    respond_to do |format|
      format.js { render :index }
    end
  end

  def reschedule
    @operations = Operation.accessible_by(@current_ability, :update)
    if @operation.failed?
      @operation.progress = 0
      @operation.scheduled_at = Time.now
      @operation.pending!
    end
    respond_to do |format|
      format.js { render :index }
    end
  end
end
