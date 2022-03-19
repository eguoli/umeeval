#!/bin/bash
# Import the variables from myumee.conf
. myumee.conf

BAL=$(umeed query bank balances $ADDR --output json | jq -r '.balances[0].amount')
REWARDS=$(umeed query distribution rewards $ADDR $OPER --output json | jq -r '.rewards[0].amount')
AMOUNT=${REWARDS%.*}

echo "Current balance: $BAL"
echo "Rewards to claim: $AMOUNT"

STATUS="$(umeed status 2>&1)"
POWER=$(echo $STATUS | jq -r ".ValidatorInfo .VotingPower")
HEIGHT=$(echo $STATUS | jq -r ".SyncInfo .latest_block_height")

TEXT="UMEE validator %23$MONIKER%0A"$'\U0001F50B'"%20Voting%20Power:%20$POWER"

# Try to unjail if voting power equal 0
if [[ $POWER -eq 0 ]]; then
        echo $PASS | umeed tx slashing unjail --from $WALLET --chain-id $CHAIN -y
        TEXT+="%20"$'\U0001F193'"%20unjail"
fi

TEXT+="%0A"$'\U0001F533'"%20Latest Block:%20$HEIGHT"
TEXT+="%0A"$'\U0001F4B0'"%20Balance:%20"
#TEXT+=$(printf %.3f $(echo "$BAL/1000000" | bc -l))
TEXT+=$BAL
TEXT+=" uumee%0A"$'\U0001F4AB'"%20Rewards to claim:%20"
#TEXT+=$(printf %.3f $(echo "$REWARDS/1000000" | bc -l))
TEXT+=${REWARDS%.*}
TEXT+=" uumee"

# Withdraw rewards
if (($AMOUNT > $CLAIM*1000000)); then
	GETREWARDS=$(echo $PASS | $(umeed tx distribution withdraw-rewards $OPER --commission --from $WALLET --chain-id $CHAIN -y))
	TEXT+="%20"$'\U000027A1'"%20withdraw"

        # Wait for tx to be confirmed so we get the updated balance
        sleep $SLEEP

        BAL=$(umeed query bank balances $ADDR --output json | jq -r '.balances[0].amount')
        echo "New balance: $BAL"
        TEXT+="%0A"$'\U0001F4B0'"%20New balance:%20"
        TEXT+=$(printf %.3f $(echo "$BAL/1000000" | bc -l))
        TEXT+=" umee"
fi

# Delegate available balance to validator
if (($BAL > $DELEGATE*1000000)); then
        echo $PASS | $(umeed tx staking delegate $OPER ${BAL}uumee --chain-id $CHAIN --from $WALLET -y)
        echo "Delegating: $BAL"
	TEXT+="%0A"$'\U0001F501'"%20Delegate:%20"
	TEXT+=$(printf %.3f $(echo "$BAL/1000000" | bc -l))
	TEXT+=" umee"
fi

# Send message via Telegram
send=$(curl -s -X POST -H "Content-Type:multipart/form-data" \
    "https://api.telegram.org/bot$BOT/sendMessage?chat_id=$TGID&text=$TEXT&parse_mode=html")
