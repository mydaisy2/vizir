class AppController < ApplicationController
  def home
    @gs = Graph.w_entity

    @metrics = []

    if params[:g]
      g = Graph.find(params[:g])
      @metrics = g.fetch_values(Time.now.to_i - 3600, Time.now.to_i)
    end

    respond_to do |format|
      format.html
      format.js { render :json => @metrics }
      format.json { render :json => @metrics }
    end
  end

  def reload_dsl
    Vizir::DSL.load_dsl

    respond_to do |format|
      format.js { render :text => "OK" }
    end
  end

  def dsl
    respond_to do |format|
      format.html { render :json => JSON.pretty_generate(Vizir::DSL.data) }
    end
  end
end
