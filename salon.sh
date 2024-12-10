#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Welcome to the salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo $1
  fi
  echo -e "Please select a service:\n1) haircut\n2) bleach\n3) perm"
  read SERVICE_ID_SELECTED

  # if service doesn't exist
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]$ ]]
  then
    # send to Main Menu
    MAIN_MENU "Input a valid number."
  else
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE

    # get customer by phone
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nYou are not in our system. Enter your name:"
      read CUSTOMER_NAME
      # add customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      echo "Inserted $CUSTOMER_NAME by $CUSTOMER_PHONE"

      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    fi

    # select service time
    echo -e "\nPlease select service time:"
    read SERVICE_TIME

    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")

    # print result
    APPOINTMENT_INFO=$($PSQL "SELECT services.name, time, customers.name FROM services INNER JOIN appointments USING(service_id) INNER JOIN customers USING(customer_id) WHERE customer_id='$CUSTOMER_ID' AND time='$SERVICE_TIME' AND service_id='$SERVICE_ID_SELECTED'")
    echo $APPOINTMENT_INFO | while read SERVICE_NAME BAR TIME BAR CUSTOMER_NAME
    do
      echo -e "\nI have put you down for a $SERVICE_NAME at $TIME, $CUSTOMER_NAME."
    done

  fi

}

MAIN_MENU
