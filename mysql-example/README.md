Example MySQL schema and mapping
================================
*This config is meant for a complete whois output as per ICANN requirements*

Before actually using it in production you will need to edit the content of the mapping.json and change TLD. You will also need to remove the inserts that i added for the purpose of having a working whois output.

### Import whois.sql
```sh
# Assuming you have created database whois
mysql -u root -p whois < whois.sql
```

### Configure your whoisd.conf

Change the host to whatever hostname mysql is running on, as well as the database name (if different) and password
```json
{
  "host": "localhost",
  "port": 43,
  "workers": 1000,
  "connections": 1000,
  "testMode": true,
  "storage": {
    "storageType": "Mysql",
    "host": "localhost",
    "port": 3306,
    "user": "whois",
    "password": "yourpassword",
    "indexBase": "whois",
    "typeTable": "domain"
  }
}

```
### Start the whoisd with -config and -mapping parameters before installing it as service and creating /etc/whoisd, in order to test if everything is working fine.
```sh
cd /path/to/your/whoisd/binary
./whoisd -config=/path/to/your/whoisd.conf -mapping=/path/to/mapping.json
```
_NOTE_: You can test now with:
```sh
whois -h localhost example.com
```

and you should get a full whois output compliant with EPP RFCs 5730-5734 as described on ICANN's [page](https://www.icann.org/resources/pages/approved-with-specs-2013-09-17-en#whois)
