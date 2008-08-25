# User: janmejay.singh
# Time: 20 Jun, 2008 8:03:26 PM
module Util
  def self.saved_games_dir_name context
    $SAVED_GAMES_DIR.gsub(/#name#/, context[:name])
  end
  
  def self.last_played_file_name context
    $LAST_PLAYED_GAME_PATH.gsub(/#name#/, context[:name])
  end
end