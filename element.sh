#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

INPUT=$1
# Function to display element details
display_element() {
  local atomic_number=$1
  ELEMENT_DATA=$($PSQL "SELECT atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$atomic_number")

  # Parse the ELEMENT_DATA
  IFS="|" read ATOMIC_NUMBER SYMBOL NAME TYPE MASS MELTING BOILING <<< "$ELEMENT_DATA"

  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
}

# Check if input is an atomic number (numeric input)
if [[ $INPUT =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$INPUT")
  
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  else
    display_element $ATOMIC_NUMBER
  fi



# Check if input is a symbol or a name (non-numeric input)
else
  # Try to find by symbol
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$INPUT'")

  if [[ -z $ATOMIC_NUMBER ]]
  then
    # If not found by symbol, try by name
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$INPUT'")
    
    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo "I could not find that element in the database."
    else
      display_element $ATOMIC_NUMBER
    fi
  else
    display_element $ATOMIC_NUMBER
  fi
fi
