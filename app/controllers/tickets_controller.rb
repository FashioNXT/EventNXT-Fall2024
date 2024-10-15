class TicketsController < ApplicationController
  def new; end

  def create
    respond_to do |format|
      format.js { head :ok } # 对于 AJAX 请求，仅返回状态码 200
    end
  end
end
