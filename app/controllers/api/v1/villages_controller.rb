class Api::V1::VillagesController < ApplicationController
  before_action :set_village

  def remaining_time
    render json: {remaining_time: @village.remaining_time}, status: 200
  end

  def go_next_day
    if @village.next_update_time <= Time.now
      noon_process
      night_process
      ActionCable.server.broadcast "room:room_channel_#{@village.room_for_all.id}", reload: true
      ActionCable.server.broadcast "room:room_channel_#{@village.room_for_wolf.id}", reload: true
      head :ok
    else
      head :unauthorized
    end
  end

  def divine
  end

  def see_soul
  end

  private

  def noon_process
    @village.lynch
    case @village.judge_end
    when 2
      @village.update!(status: :ended)
    when 1
      @village.update!(status: :ended)
    else
      false
    end
  end

  def night_process
    return if @village.ended?
    @village.attack
    case @village.judge_end
    when 2
      @village.update!(status: :ended)
    when 1
      @village.update!(status: :ended)
    else
      @village.update!(day: @village.day + 1, next_update_time: Time.now + @village.discussion_time.minutes)
      @village.prepare_records
    end
  end

  def set_village
    @village = Village.find(params[:id])
  end
end
