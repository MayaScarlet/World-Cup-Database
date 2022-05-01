#! /bin/bash

if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  # insert winner teams
  if [[ $WINNER != 'winner' ]]; then
    # get winner team
    WINNER_TEAM=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")

    # if winner team is not found
    if [[ -z $WINNER_TEAM ]]; then
      # insert winner team
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]; then
        echo "Insert into teams, $WINNER"
      fi
    fi
  fi

  # insert opponent teams
  if [[ $OPPONENT != 'opponent' ]]; then
    # get opponent team
    OPPONENT_TEAM=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if opponent team is not found
    if [[ -z $OPPONENT_TEAM ]]; then
      # insert opponent team
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]; then
        echo "Insert into teams, $OPPONENT"
      fi
    fi
  fi

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  # insert games info
  if [[ -n $WINNER_ID || -n $OPPONENT_ID ]]; then
    if [[ $YEAR != 'year' ]]; then
      GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id)
        VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID)")
      if [[ $GAMES_RESULT == "INSERT 0 1" ]]; then
        echo "Insert into games: $WINNER_ID, $OPPONENT_ID"
      fi
    fi
  fi
done
