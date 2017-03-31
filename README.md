
Openprovider Whois Daemon
=========================

*A quick and easy way to setup your own WHOIS server with Elasticsearch/MySQL storage*

Whois Daemon complies with the requirements of [ICANN](https://www.icann.org/resources/pages/approved-with-specs-2013-09-17-en)

[![Build Status](https://travis-ci.org/openprovider/whoisd.svg?branch=master)](https://travis-ci.org/openprovider/whoisd)

**Whois Daemon** represents a light server which provide fast way to produce whois information.

### Install

This package is "go-gettable", just do:

```sh
go get github.com/openprovider/whoisd

# For MySQL support also run:
go get github.com/go-sql-driver/mysql
```

### Testing

```sh
whoisd -t -config=test/testconfig.conf -mapping=test/testmapping.json
```

### Running

Start of whoisd:

```sh
sudo whoisd
```
or start as daemon
```sh
sudo whoisd install
sudo whoisd start
```

This will bring up whoisd listening on port 43 for client communication.

### Usage

```
whoisd - Whois Daemon

Usage:
  whoisd install | remove | start | stop | status
  whoisd [ -t | --test ] [ -option | -option ... ]
  whoisd -h | --help
  whoisd -v | --version

Commands:
  install           Install as service (is only valid for Linux and Mac Os X)
  remove            Remove service
  start             Start service
  stop              Stop service
  status            Check service status

  -h --help         Show this screen
  -v --version      Show version
  -t --test         Test mode

Options:
  -config=<path>    Path to config file (used in /etc/whoisd/whoisd.conf)
  -mapping=<path>   Path to mapping file (used in /etc/whoisd/conf.d/mapping.json)
  -host=<host/IP>   Host name or IP address
  -port=<port>      Port number
  -work=<number>    Number of active workers (default 1000)
  -conn=<number>    Number of active connections (default 1000)
  -storage=<type>   Type of storage (Elasticsearch, Mysql or Dummy for testing)
  -shost=<host/IP>  Storage host name or IP address
  -sport=<port>     Storage port number
  -suser=<name>     User name for storage login
  -spassword=<***>  Password of storage user
  -base=<name>      Storage index or database name
  -table=<name>     Storage type or table name
```

### Config

The config file should be in /etc/whoisd/whoisd.conf. Of course possible to load config settings from any other place through -config option. If config file is absent, used predefined configuration below: 

```json
{
  "host": "0.0.0.0",
  "port": 43,
  "workers": 1000,
  "connections": 1000,
  "storage": {
    "storageType": "Dummy",
    "host": "localhost",
    "port": 9200,
    "user": "test",
    "password": "test",
    "indexBase": "whois",
    "typeTable": "domain"
  }
}
```
_NOTE_: Valid storage types: Elasticsearch, Mysql, Dummy. Dummy storage has two records for testing: "example.tld" and "google.com". You can test it: 
```sh
whois -h localhost example.tld
```
or
```sh
whois -h localhost google.com
```
These fixtures placed in "storage" package directory.


### Mapping

All required fields for whoisd must be defined in the mapping file. The mapping file represent all fields in your database as key names in the whoisd. The mapping file should be in /etc/whoisd/conf.d/mapping.json. It possible to load mapping file through -mapping option. The context of the mapping file is described below:

```json
[
  {
    "TLDs": ["eu"],
    "Fields" : {
      "01": {
        "key": "Domain Name: ",
        "name": ["name"],
        "related": "name"
      },
      "02": {
        "key": "Registry Domain ID: ",
        "name": ["domainId"],
        "related": "name"
      },
      "03": {
        "key": "Registrar WHOIS Server: ",
        "value": ["whois.yourwhois.eu"]
      }
    }
  },
  {
    "TLDs": ["com", "net"],
    "Fields" : {
      "01": {
        "key": "Domain Name: ",
        "name": ["name"],
        "related": "name"
      },
      "02": {
        "key": "Registry Domain ID: ",
        "name": ["domainId"],
        "related": "name"
      },
      "03": {
        "key": "Registrar WHOIS Server: ",
        "value": ["whois.yourwhois.eu"]
      }
    }
  }
]
```

- "TLDs" - a list of TLDs which accepted by Whois Daemon for specified fields
- "Fields" - a list of fields from "01" to last number "nn" in ascending order
- "key" - a label for the field (preinstalled config file has keys according to ICANN requirements)
- "value" - use it if the field has constant value (not defined field from the database)
- "name" - a name of the field in a database, if the field has not constant value ("value" is not defined)
- "related" - a name of the field in a database through which a request for 

```json
[
  {

      "06": {
        "key": "Creation Date: ",
        "name": ["creationDate"],
        "format": "{date}",
        "related": "name"
      },
   
      "07": {
        "key": "Expiration Date: ",
        "name": ["expirationDate"],
        "format": "{shortdate}",
        "related": "name"
      }
    }
  }
]
```

- "format" - special instructions to indicate how to display field, the examples shown below
- "{date}" - used in the format to indicate that the field is a 'date' and need special formatting of the date RFС3339
- "{shortdate}" - used in the format to indicate that the field is a 'date' and need special formatting of the date in short format like '2006.02.03'

```json
[
  {

      "12": {
        "key": "Domain Status: ",
        "name": ["domainStatus"],
        "multiple": true,
        "related": "name"
      },

      "52": {
        "key": "Name Server: ",
        "name": ["name"],
        "multiple": true,
        "related": "nsgroupId",
        "relatedBy": "nsgroupId",
        "relatedTo": "nameserver"
      }

  }
]
```

- "multiple" - if this option is set to 'true', each value will be repeated in whois output with the same label like that:
```
Name Server: ns1.example.com
Name Server: ns2.example.com
Name Server: ns3.example.com
```
- "relatedBy" - a name of the field in a database through which related a request for 
- "relatedTo" - a name of the table/type in a database through which made a relation

```json
[
  {

      "13": {
        "key": "Registry Registrant ID: ",
        "name": ["handle"],
        "hide": true,
        "related": "ownerHandle",
        "relatedBy": "handle",
        "relatedTo": "customer"
      }

  }
]
```

- "hide" - if this option is set to 'true' and value is empty the field will not shown in whois output

```json
[
  {

      "14": {
        "key": "Registrant Name: ",
        "name": ["name.fullName"],
        "related": "ownerHandle",
        "relatedBy": "handle",
        "relatedTo": "customer"
      },

      "40": {
        "key": "Tech Name: ",
        "name": ["name.firstName", "name.lastName"],
        "related": "techHandle",
        "relatedBy": "handle",
        "relatedTo": "customer"
      }

  }
]
```

- "name": ["name.fullName"] - use dot notation for embedded fields (MySQL storage not allowed)
- "name": ["name.firstName", "name.lastName"] - all values of the fields will be joined by default

```json
[
  {

      "01": {
        "key": "domain: ",
        "name": ["name"],
        "format": "{idn}",
        "multiple": true,
        "related": "name"
      },

      "21": {
        "key": "Registrant Phone: ",
        "name": ["phone.countryCode", "phone.areaCode", "phone.subscriberNumber"],
        "format": "{string}.{string}{string}",
        "related": "ownerHandle",
        "relatedBy": "handle",
        "relatedTo": "customer"
      }

  }
]
```

- "format": "{idn}" - indicate that the field "name" (domain name) need to decode according to IDN in UTF-8
- "format": "{string}.{string}{string}" - indicate that the fields ["phone.countryCode", "phone.areaCode", "phone.subscriberNumber"] need special formatting "{string}.{string}{string}" (they are not simple joined)
- {string} - represent one string field in format option


```json
[
  {

      "14": {
        "key": "Registrant Name: ",
        "name": ["name.firstName", "name.lastName"],
        "related": "ownerHandle",
        "relatedBy": "handle",
        "relatedTo": "customer",
        "replacedBy": "15"
      },

      "15": {
        "key": "Registrant Organization: ",
        "name": ["companyName"],
        "related": "ownerHandle",
        "relatedBy": "handle",
        "relatedTo": "customer"
      }

  }
]
```

- "replacedBy" - it contains the number of field that replaces this field. If the field is referenced by "replacedBy" has non-empty value, then this field will not show in whois output, because this field should be replaced by the field specified in 'ReplacedBy'. As a result will be show "Registrant Name: " or "Registrant Organization: " but not all together.

```json
[
  {
      "55": {
        "key": "",
        "value": [""],
        "format": ">>> Last update of WHOIS database: {date} <<<"
      }
  }
]
```

- a example of formating where used undefined tag "{date}", because a name of the field has not present, "{date}" will be replaced by CURRENT date in RFC3339 format


## Todo

- in memory storage
- Rest API
- update storage records by Rest API


## Contributors (unsorted)

 - [Igor Dolzhikov](https://github.com/takama)
 - [Armin Pech](https://github.com/pecharmin)
 - [Rafael Fernández López](https://github.com/ereslibre)

All the contributors are welcome. If you would like to be the contributor please accept some rules.
- The pull requests will be accepted only in "develop" branch
- All modifications or additions should be tested

Thank you for your understanding!

## License

[MIT License](https://github.com/openprovider/whoisd/blob/master/LICENSE)
