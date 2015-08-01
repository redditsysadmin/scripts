# heartbeat
a simple heartbeat script that checks to see if a server is online every five minutes. if it's not, it sends a text message using the twilio-sms api.

```bash
git clone https://github.com/joshuaterrill/heartbeat.git
cd heartbeat
chmod 775 twilio-sms.sh
chmod 775 heartbeat.sh
#optionally, you can run 'screen' and run the script in another terminal tab
./heartbeat.sh -s <server> -r <rate> -t <recipient>
```

if a server is behind a firewall and cannot be pinged, you may install hping3

```bash
sudo apt-get install hping3
```

and replace the ping with

```bash
if hping3 -S  $SERVER -p 8011 -c 1 > /dev/null;
```

#### references
[twilio-sms documentation](https://www.twilio.com/labs/bash/sms)
