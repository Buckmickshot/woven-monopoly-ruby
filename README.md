# Woven Monopoly Simulator (Ruby)

Deterministic Monopoly-style game simulator for the Woven coding task.

Given a JSON board and one or more JSON roll sequence, the program deterministically simulates the game and reports:
- winner (or draw)
- ranking
- final cash by player
- final board position by player
- optional turn-by-turn log

The simulation follows the required baseline rules from the task specification

## Requirements

- Ruby 3.0+
- No third-party gems required

## Run

Run a single game in text mode (roll file must be included):

```bash
ruby main.rb --rolls example_roll_file.json
```

Run both provided games and output JSON:

```bash
ruby main.rb --rolls data/rolls_1.json --rolls data/rolls_2.json --format json
```

Include detailed turn log:

```bash
ruby main.rb --rolls data/rolls_2.json --print-turn-log
```

Write JSON output to a file:

```bash
ruby main.rb --rolls data/rolls_2.json --format json --output-file output.json
```

## CLI Options

- `--board`: board file path (default: `data/board.json`)
- `--rolls`: roll file path (required) (repeat this argument to run multiple games with same board)
- `--players`: player names in turn order (space-separated) (default: Peter Billy Charlotte Sweedal)
- `--start-money`: starting cash per player (must be non-negative integer)
- `--pass-go`: amount awarded when passing GO (must be non-negative integer)
- `--print-turn-log`: include per-turn event log (boolean)
- `--format`: `text` or `json`
- `--output-file`: optional JSON output file path

## Testing

Run all tests:

```bash
ruby tests/test_game.rb
```

The test suite includes:
- input validation (`load_rolls`, `load_board`)
- rule-level unit tests (buying, pass GO, rent multiplier, bankruptcy stop)
- integration tests that verify full deterministic outcomes for different boards and rolls

## Project Structure

- `src/tiles.rb`
  - board tile abstractions (`Tile`, `GoTile`)
- `src/property.rb`
  - property behavior (ownership, rent, landing effect)
- `src/player.rb`
  - player state and money/movement operations
- `src/board.rb`
  - board loading, validation, and board helpers
- `src/game.rb`
  - deterministic game engine and result model
- `main.rb`
  - CLI argument parsing, orchestration, output formatting
- `tests/test_game.rb`
  - unit + integration tests

## Design Overview

Core design choices:
- Each game componenet handles their distinct responsibilities using Separation of Concerns principle (e.g `Game`, `Property`, `Tile`)
- Go tile and Property are subclasses of Tile, allowing extensibility
- CLI args supports easy mutations to game parameters
- Combination of input/output, unit and integration tests assert core rules and deterministic game outcomes.
- GameConfig centralises core game parameters such as starting money, pass GO, and end-policy.

## Assumptions

- There must be at least 1 player, else there is no-one to play the game.
- Starting money must be a non-negative integer, else the game would likely end quickly and be boring.
- GO tile is first dict in the board json list.
- Pass Go reward must be a non-negative integer, else the game would be designed to end quickly.
- The rent of a property is equal to the price of the property, else rents could be floats.
- Forced property purchase still occurs even if it causes bankruptcy.
- Bankruptcy is defined as cash below zero.
- There can be multiple winners and players with same ranking.

## Extensibility Notes

The project is structured to support future rules with minimal change to existing code:
- add new tile types by extending `Tile` and implementing `land(...)`
- keep rule variants configurable via `GameConfig`
- add optional systems (chance cards, jail, stations, taxes) as new tile classes and game hooks
- run alternate board layouts and roll sequences via CLI without code changes

Potential next extensions:
- chance deck and card actions
- jail and turn-skipping state
- Different property types
- distinct rent rules
- configurable bankruptcy policy or game-end condition