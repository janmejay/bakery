# User: janmejay.singh
# Time: 20 Jun, 2008 8:03:26 PM
module Util
  def self.saved_games_dir_name context
    $SAVED_GAMES_DIR.gsub(/#name#/, context[:name])
  end
  
  def self.last_played_file_name context
    saved_game_file_name(last_played_game_dump(context))
  end

  def self.last_played_level_file_name context
    last_level_file_name(last_played_game_dump(context))
  end

  def self.last_played_game_name context
    $LAST_PLAYED_GAME_NAME.gsub(/#name#/, context[:name])
  end

  def self.last_played_game_dump context
    game_dump_for(last_played_game_name(context))
  end

  def self.game_dump_for name
    name + $BAKERY_FILE_EXT
  end

  def self.game_dump_files_for game_dump_name
    [saved_game_file_name(game_dump_name), last_level_file_name(game_dump_name)]
  end
  
  def self.base_data_dir_path context
    $PLAYER_DATA_BASE_PATH.gsub(/#name#/, context[:name])
  end

  private
  def self.saved_game_file_name for_dump
    for_dump + $SAVED_FILE_EXT
  end

  def self.last_level_file_name for_dump
    for_dump + $LEVEL_FILE_EXT
  end
end
