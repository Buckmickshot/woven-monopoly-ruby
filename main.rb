require 'json'
require 'optparse'
require_relative 'src/board'
require_relative 'src/game'

# Loads and validates a sequence of dice rolls from a JSON file.
def load_rolls(rolls_path)
  raw_content = JSON.parse(File.read(rolls_path))

  unless raw_content.is_a?(Array)
    raise ArgumentError, "Rolls file '#{rolls_path}' must be an array."
  end

  unless raw_content.all? { |roll| roll.is_a?(Integer) && roll > 0 }
    raise ArgumentError, "Rolls file '#{rolls_path}' must contain positive integer rolls only."
  end

  raw_content
end

def ordinal(n)
  if (4..20).include?(n % 100)
    suffix = "th"
  else
    suffix = {1 => "st", 2 => "nd", 3 => "rd"}.fetch(n % 10, "th")
  end
  "#{n}#{suffix}"
end

def print_ranking(result)
  puts "\nRanking:"

  rank_pos = 1
  result.ranking.each do |cash, players|
    label = ordinal(rank_pos)
    names = players.join(", ")

    if players.length > 1
      puts "#{label} (tie): #{names} ($#{cash})"
    else
      puts "#{label}: #{names} ($#{cash})"
    end

    rank_pos += players.length
  end
end

# Determines winner or draw information from ranking.
def compute_winner(result)
  _, top_players = result.ranking.first

  if top_players.length == 1
    {
      winner: top_players.first,
      is_draw: false,
      draw_players: [],
    }
  else
    {
      winner: "draw",
      is_draw: true,
      draw_players: top_players,
      draw_count: top_players.length,
    }
  end
end

# Converts a GameResult into a JSON-serialisable dictionary.
def result_to_dict(result)
  winner_info = compute_winner(result)

  # build structured ranking
  ranking_output = []
  rank_pos = 1

  result.ranking.each do |cash, players|
    entry = {
      rank: ordinal(rank_pos),
      cash: cash,
      players: players,
      is_tie: players.length > 1,
    }
    ranking_output << entry
    rank_pos += players.length
  end

  {
    winner: winner_info[:winner],
    is_draw: winner_info[:is_draw],
    draw_players: winner_info[:draw_players],
    draw_count: winner_info[:draw_count] || 0,
    ranking: ranking_output,
    cash_by_player: result.cash_by_player,
    position_by_player: result.position_by_player,
    turns_played: result.turns_played,
    turn_log: result.turn_log,
  }
end

# Prints a human-readable summary of a game result,
# including winner/draw, ranking, final money, positions, and optional turn log.
def print_text_results(roll_path, result)
  puts "Game: #{roll_path}"
  puts "Turns played: #{result.turns_played}"

  # winner
  winner_info = compute_winner(result)
  if winner_info[:is_draw]
    names = winner_info[:draw_players].join(", ")
    puts "Result: #{winner_info[:draw_count]}-way draw between #{names}"
  else
    puts "Winner: #{winner_info[:winner]}"
  end

  print_ranking(result)

  puts "\nFinal money:"
  result.cash_by_player.each do |player_name, cash|
    puts "- #{player_name}: $#{cash}"
  end

  puts "\nFinal positions:"
  result.position_by_player.each do |player_name, position|
    puts "- #{player_name}: #{position}"
  end

  if result.turn_log
    puts "\nTurn log:"
    result.turn_log.each do |entry|
      puts "- #{entry}"
    end
  end

  puts
end

# Parses command-line arguments for configuring game execution.
def parse_args
  options = {
    board: "data/board.json",
    players: ["Peter", "Billy", "Charlotte", "Sweedal"],
    start_money: 16,
    pass_go: 1,
    print_turn_log: false,
    format: "text",
    output_file: nil,
    rolls: [],
  }

  parser = OptionParser.new do |opts|
    opts.banner = "Simulate deterministic Woven Monopoly games."

    opts.on("--board PATH", "Path to board JSON file.") do |path|
      options[:board] = path
    end

    opts.on("--rolls PATH", "Path to a rolls JSON file. Provide this flag multiple times to run multiple games.") do |path|
      options[:rolls] << path
    end

    opts.on("--players NAMES", "Player names in turn order (space-separated).") do |names|
      options[:players] = names.split(" ")
    end

    opts.on("--start-money AMOUNT", Integer, "Starting money for each player.") do |amount|
      options[:start_money] = amount
    end

    opts.on("--pass-go AMOUNT", Integer, "Amount received when passing GO.") do |amount|
      options[:pass_go] = amount
    end

    opts.on("--print-turn-log", "Include per-turn decision log.") do
      options[:print_turn_log] = true
    end

    opts.on("--format FORMAT", ["text", "json"], "Output format (text or json).") do |format|
      options[:format] = format
    end

    opts.on("--output-file PATH", "Path to output file for JSON results.") do |path|
      options[:output_file] = path
    end
  end

  parser.parse!

  if options[:rolls].empty?
    raise OptionParser::MissingArgument, "At least one --rolls file must be provided"
  end

  options
end

# Runs one deterministic simulation per rolls file.
# A fresh board is loaded for each game to avoid cross-game state leakage.
def simulate_games(board_path:, roll_paths:, config:, include_turn_log: false)
  all_results = {}

  roll_paths.each do |roll_path|
    board = load_board(board_path)
    game = Game.new(board, config)
    rolls = load_rolls(roll_path)

    result = game.play(rolls, include_turn_log)
    all_results[roll_path] = result
  end

  all_results
end

# Entry point for running simulations.
def main
  args = parse_args
  players = args[:players]

  config = GameConfig.new(
    player_names: players,
    starting_money: args[:start_money],
    pass_go_reward: args[:pass_go],
  )

  all_results = simulate_games(
    board_path: args[:board],
    roll_paths: args[:rolls],
    config: config,
    include_turn_log: args[:print_turn_log]
  )

  all_results.each do |roll_path, result|
    if args[:format] == "text"
      print_text_results(roll_path, result)
    end
  end

  if args[:format] == "json"
    output = all_results.map do |roll_path, result|
      [roll_path, result_to_dict(result)]
    end.to_h

    if args[:output_file]
      File.write(args[:output_file], JSON.pretty_generate(output))
    else
      puts JSON.pretty_generate(output)
    end
  end
end

if __FILE__ == $0
  main
end