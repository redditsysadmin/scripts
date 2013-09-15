# heartbeat
a simple heartbeat script that checks to see if a server is online every five minutes. if it's not, it sends a text message using the twilio-sms api.

```bash
git clone https://github.com/joshuaterrill/heartbeat.git
cd heartbeat
chmod 775 twilio-sms.sh
chmod 775 heartbeat.sh
#optionally, you can run 'screen' and run the script in another terminal tab
./heartbeat.sh
```

#### references
[twilio-sms documentation](https://www.twilio.com/labs/bash/sms)
