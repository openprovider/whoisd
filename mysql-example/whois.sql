-- MySQL dump 10.14  Distrib 5.5.52-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: whois
-- ------------------------------------------------------
-- Server version	5.5.52-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `handle` varchar(50) NOT NULL DEFAULT '' COMMENT 'contact handle from registry (if sent)',
  `firstName` varchar(100) NOT NULL DEFAULT '' COMMENT 'first name',
  `lastName` varchar(100) NOT NULL DEFAULT '' COMMENT 'last name',
  `companyName` varchar(100) NOT NULL DEFAULT '',
  `addressStreet` varchar(255) NOT NULL COMMENT 'address street',
  `addressCity` varchar(255) NOT NULL COMMENT 'address city',
  `addressState` varchar(255) NOT NULL,
  `addressZipCode` varchar(10) NOT NULL DEFAULT '' COMMENT 'address zip code (varchar since it can also cintain letters)',
  `addressCountry` varchar(100) NOT NULL DEFAULT '',
  `phoneNumber` varchar(25) NOT NULL DEFAULT '' COMMENT 'phone area code (can contain +)',
  `faxNumber` varchar(25) NOT NULL DEFAULT '' COMMENT 'fax area code (can contain +)',
  `email` varchar(255) NOT NULL DEFAULT '' COMMENT 'email address',
  PRIMARY KEY (`id`),
  KEY `handle` (`handle`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (1,'65CE471593A03D','Example','Customer','Example Company LTD','1st Any Street','New York','New York','10011','United States','+1.234567890','','contact@example.com');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domain`
--

DROP TABLE IF EXISTS `domain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domain` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT 'domain name',
  `domainId` varchar(50) NOT NULL DEFAULT '' COMMENT 'ROID',
  `nsgroupId` int(11) unsigned NOT NULL COMMENT 'group of nameservers',
  `resellerId` int(11) unsigned NOT NULL,
  `staticInfoId` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'staticId always 1 to relate to staticInfo table',
  `ownerHandle` varchar(50) NOT NULL DEFAULT '' COMMENT 'owner handle',
  `techHandle` varchar(50) NOT NULL DEFAULT '' COMMENT 'tech handle',
  `adminHandle` varchar(50) NOT NULL DEFAULT '' COMMENT 'admin handle',
  `billingHandle` varchar(50) NOT NULL DEFAULT '' COMMENT 'billing handle',
  `dnssec` varchar(20) NOT NULL DEFAULT 'unsigned' COMMENT 'dnssec can be signed or unsigned',
  `updatedDate` datetime NOT NULL COMMENT 'domain last update date',
  `creationDate` datetime NOT NULL COMMENT 'domain creation date',
  `expirationDate` datetime NOT NULL COMMENT 'domain expiration date',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COMMENT='domain data';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domain`
--

LOCK TABLES `domain` WRITE;
/*!40000 ALTER TABLE `domain` DISABLE KEYS */;
INSERT INTO `domain` VALUES (1,'example.com','16862114612_DOMAIN-CAM',1,0,1,'65CE471593A03D','65CE471593A03D','65CE471593A03D','65CE471593A03D','unsigned','2017-06-23 02:11:02','2017-06-23 01:11:39','2018-06-23 01:11:39');
/*!40000 ALTER TABLE `domain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domainStatus`
--

DROP TABLE IF EXISTS `domainStatus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domainStatus` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `status` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `name` (`name`(191))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domainStatus`
--

LOCK TABLES `domainStatus` WRITE;
/*!40000 ALTER TABLE `domainStatus` DISABLE KEYS */;
INSERT INTO `domainStatus` VALUES (1,'example.com','clientHold https://icann.org/epp#clientHold'),(2,'test.cam','serverTransferProhibited https://icann.org/epp#serverTransferProhibited');
/*!40000 ALTER TABLE `domainStatus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nameserver`
--

DROP TABLE IF EXISTS `nameserver`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nameserver` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `nsgroupId` int(11) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `nsgroupId` (`nsgroupId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nameserver`
--

LOCK TABLES `nameserver` WRITE;
/*!40000 ALTER TABLE `nameserver` DISABLE KEYS */;
INSERT INTO `nameserver` VALUES (1,1,'ns1.example.com'),(2,1,'ns2.example.com');
/*!40000 ALTER TABLE `nameserver` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reseller`
--

DROP TABLE IF EXISTS `reseller`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reseller` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `resellerId` int(11) unsigned DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `resellerId` (`resellerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reseller`
--

LOCK TABLES `reseller` WRITE;
/*!40000 ALTER TABLE `reseller` DISABLE KEYS */;
/*!40000 ALTER TABLE `reseller` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staticInfo`
--

DROP TABLE IF EXISTS `staticInfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staticInfo` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `whoisServer` varchar(100) NOT NULL DEFAULT '',
  `registrarUrl` varchar(100) NOT NULL DEFAULT '',
  `companyName` varchar(100) NOT NULL DEFAULT '',
  `ianaId` varchar(10) NOT NULL DEFAULT '',
  `abuseEmail` varchar(255) NOT NULL,
  `abusePhone` varchar(25) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staticInfo`
--

LOCK TABLES `staticInfo` WRITE;
/*!40000 ALTER TABLE `staticInfo` DISABLE KEYS */;
INSERT INTO `staticInfo` VALUES (1,'whois.example.com','https://example.com','Some Company LTD','3785','abuse@example.com','+1.234567890');
/*!40000 ALTER TABLE `staticInfo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `whois`
--

DROP TABLE IF EXISTS `whois`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whois` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `updatedDate` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `whois`
--

LOCK TABLES `whois` WRITE;
/*!40000 ALTER TABLE `whois` DISABLE KEYS */;
/*!40000 ALTER TABLE `whois` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-09-07  7:33:50

