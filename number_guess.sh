#!/bin/bash
# Number-guessing game with postgreSQL db.

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate the secret number
SECRET_NUMBER=$(($RANDOM%1000+1))

echo Enter your username:
read USERNAME

# Get user. If existing, echo user info. Otherwise save to db.
USER_SEARCH=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
if [[ -z $USER_SEARCH ]] 
then
  echo Welcome, $USERNAME! It looks like this is your first time here.

  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
else
  IFS="|" read -r USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< $USER_SEARCH
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

# Update number of games played by this user.
INCREMENT_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = (games_played + 1) WHERE username = '$USERNAME'")

# Init number of guesses
NUMBER_OF_GUESSES=0;

echo Guess the secret number between 1 and 1000:
read USER_GUESS

# While loop breaks only after number is guessed.
while [[ $USER_GUESS != $SECRET_NUMBER ]]
do
  # Make sure input is an integer
  if [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    # Indicate lower or higher, and increment number of guesses.
    if [[ $USER_GUESS -gt $SECRET_NUMBER ]]
    then 
      echo It\'s lower than that, guess again:
      ((NUMBER_OF_GUESSES++))
    elif [[ $USER_GUESS -lt $SECRET_NUMBER ]]
    then
      echo It\'s higher than that, guess again:
      ((NUMBER_OF_GUESSES++))
    fi
  else
    echo That is not an integer, guess again:
  fi

  read USER_GUESS
done

((NUMBER_OF_GUESSES++))

# Update best game if the number of guesses was lower than best game
if [[ $NUMBER_OF_GUESSES < $BEST_GAME || $BEST_GAME -eq 0 ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
fi

echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!