class EventsController < ApplicationController
  before_action :set_event, only: %i[ show edit update destroy ]

  # GET /events or /events.json
  def index
    @events = Event.where(user: current_user).order(:start_date)
  end

  # GET /events/1 or /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @event = Event.new(event_params)
    @event.user = current_user

    start_date = @event.start_date
    end_date = @event.end_date

    overlapping_events = Event.where(user: current_user)
                          .where('? BETWEEN start_date AND end_date OR 
                                  ? BETWEEN start_date AND end_date', 
                                  start_date, end_date)

    print overlapping_events.to_a

    respond_to do |format|
      if @event.end_date >= @event.start_date and overlapping_events.to_a.empty?
        if @event.save
          format.html { redirect_to @event, notice: "Evento criado." }
          format.json { render :show, status: :created, location: @event }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      else
        flash.now[:alert] = "Há outro evento no mesmo horário ou a data de fim é anterior à de início" 
        format.html { render :new, status: :unprocessable_entity}
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    event = Event.new(event_params)

    start_date = @event.start_date
    end_date = @event.end_date

    overlapping_events = Event.where(user: current_user)
                          .where('? BETWEEN start_date AND end_date OR 
                                  ? BETWEEN start_date AND end_date', 
                                  start_date, end_date)

    print overlapping_events.to_a

    respond_to do |format|
      if event.end_date >= event.start_date and overlapping_events.to_a.empty? 
        if @event.update(event_params)
          format.html { redirect_to @event, notice: "Evento atualizado." }
          format.json { render :show, status: :ok, location: @event }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      else
        flash.now[:alert] = "Há outro evento no mesmo horário ou a data de fim é anterior à de início" 
        format.html { render :edit, status: :unprocessable_entity}
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: "Evento excluído." }
      format.json { head :no_content }
    end
  end

  def calendar
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @events_by_date = Event.where(user: current_user)
                            .order(:start_date)
                            .group_by_day(&:start_date)
    puts @events_by_date
    #.includes(:guests)
    @events = Event.where(user: current_user)
                    .order(:start_date)
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(:description, :start_date, :end_date, :user_id)
    end

end
