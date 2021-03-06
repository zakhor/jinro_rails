module VillagesHelper
  def datetime_display(start_at)
    if start_at
      start_at.strftime('%-m/%-d %H:%M')
    else
      '-'
    end
  end

  def link_to_profile(player)
    return "-" unless player.user
    link_to(player.user.username, users_profile_path(player.user.profile), target: "_blank")
  end

  def messages_of_result(results)
    return [] unless results
    messages = []
    results.each do |k, v|
      messages << "#{k}は#{human_or_werewolf(v)}です"
    end
    messages
  end

  def join_message(village, player)
    "#{village.players.count}人目、#{player.username}が参加しました"
  end

  def exit_message(player)
    "#{player.username}が退出しました"
  end

  def kick_message(player)
    "#{player.username}がキックされました"
  end

  def update_message(village)
    message = "作成者により村が更新されました\n"
    add_village_settings(village, message)
  end

  def add_village_settings(village, message)
    message << "村名: #{village.name}\n"
    message << "人数: #{village.player_num} 人\n"
    message << "議論時間: #{village.discussion_time} 分\n"
    message << "投票先の開示: #{I18n.t("activerecord.attributes.village.show_vote_target_value.#{village.show_vote_target}")}\n"
    message << "開始予定: #{datetime_display(village.start_at)}\n"
  end

  def ruin_message(village)
    "#{village.name}は廃村になりました"
  end

  def ready_to_start_message
    "全ての村人が集まりました\n作成者は「ゲーム開始」を押してください"
  end

  def start_message(village)
    message = ""
    add_village_settings(village, message)
    message << "この中には"
    Player.roles.keys.each do |role|
      count = role_count(village, role)
      next if count == 0
      message << "、#{I18n.t("activerecord.attributes.player.role_enums.#{role}")}が#{count}名"
    end
    message << "います\n"
    message << "それでは今から、人狼を見つけるために話し合ってください"
  end

  def noon_message(village)
    message = ""
    if village.show_vote_target
      add_vote_target(village, message)
    else
      add_the_number_of_votes(village, message)
    end
    message << "投票の結果、#{village.result_of_today.voted_player.username}は処刑された"
  end

  def add_vote_target(village, message)
    village.records.where(day: village.day).includes(:player).each do |record|
      if record.vote_target
        message << "#{record.player.username}は #{record.vote_target.username} に投票した\n"
      else
        message << "#{record.player.username}は投票しなかった\n"
      end
    end
  end

  def add_the_number_of_votes(village, message)
    village.number_of_votes.each do |username, count|
      message << "#{username}は #{count}票だった\n"
    end
  end

  def night_message(village)
    message = "夜が明けた\n"
    if village.result_of_today.attacked_player
      message << "昨晩の犠牲者は #{village.result_of_today.attacked_player.username} だった"
    else
      message << "昨晩は犠牲者がいなかったようだ"
    end
  end

  def morning_message(village)
    message = "現在の生存者は"
    village.players.alive.each do |player|
      message << "、#{player.username}"
    end
    message << "の#{village.players.alive.count}名だ"
  end

  def end_message(village)
    message = ""
    if village.werewolf_win?
      message << "もう人狼に抵抗できるほど村人は残っていない\n"
      message << "人狼は残った村人を全て食らい、村を去っていった"
    elsif village.human_win?
      message << "全ての人狼は息絶えた\n"
      message << "村人は人狼との戦いに勝利したのだ"
    end
  end

  def reveal_message(village)
    message = "プレイヤーの役職は以下の通りでした\n"
    village.players.each do |player|
      message << "#{player.username} : #{I18n.t("activerecord.attributes.player.role_enums.#{player.role}")}\n"
    end
    message
  end

  private

  def human_or_werewolf(bool)
    return "人間" if bool
    "人狼"
  end

  def role_count(village, role)
    Settings.role_list[village.player_num].count(role)
  end
end
