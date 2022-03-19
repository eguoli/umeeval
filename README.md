# Autodelegate Bash Script For UMEE Validator Node
> With Notifications via Telegram

1. To use use this script you may need to install additional packages:

```bash
apt-get install curl jq bc # Debian/Ubuntu
yum install curl jq bc # CentOS
```

2. Set the variables in myumee.conf:

```bash
GOBIN="" # UMEE cli folder with full path, e.g. /root/go/bin
ADDR="" # UMEE wallet address
OPER="" # UMEE validator address
MONIKER="" # UMEE node moniker name 
WALLET="" # UMEE wallet name
PASS="" # UMEE wallet password
FEES="0.1" # Set the transaction fees amount in umee
CLAIM=100 # Minimum rewards amount to withdraw in umee
DELEGATE=1000 # Minimum amount to delegate in umee
SLEEP=10 # Wait for N seconds for the transaction to be confirmed so we get an updated balance

BOT="" # Telegram bot api from @BotFather
TGID="" # Your Telegram ID
```
- To get the Telegram bot API key just talk to @BotFather and set up your own bot.
- To define your Telegram ID send a message to your newly created bot and open in browser https://api.telegram.org/botINSERTAPIKEY/getUpdates - in the json string returned you will find your "id".

3. Make the file with your variables not readable for anyone but owner

```bash
chmod 400 myumee.conf
```

4. Make the main script executable

```bash
chmod +x myumee.sh
```

5. Set up a cron job

```bash
crontab -u <user> -e
```

- Set the full path to the script

```bash
# m h  dom mon dow   command
0 * * * *	/<path>/myumee.sh
```
This setting will run a script every hour at :00 minutes. Set as */10 instead to run this job every 10 minutes.

---

Please feel free to contact me @eguoli on Telegram ;)
