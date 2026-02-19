#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Check if user exists
USER_ID=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  # User does not exist
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # User exists, fetch stats
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

# Game Loop
while true
do
  read GUESS

  # Check if input is integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    # Increment guess count (valid guess)
    ((GUESS_COUNT++))

    # Check guess
    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      # Correct Guess
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
      
      # Update Database
      # 1. Get current games_played and increment
      # (If new user, they are 0, so result is 1)
      if [[ -z $GAMES_PLAYED ]]
      then
        GAMES_PLAYED=0
        BEST_GAME=0
      fi
      
      NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
      
      # 2. Update Best Game logic
      # If best_game is 0 (new user) OR current guesses < best_game
      if [[ $BEST_GAME -eq 0 || $GUESS_COUNT -lt $BEST_GAME ]]
      then
        UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE username='$USERNAME'")
      fi

      # 3. Save new game count
      UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME'")
      
      break
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
done
# Finished logic part 1

# This is a comment 

# Ready for submission
