-- MySQL dump 10.11
--
-- Host: localhost    Database: clindb
-- ------------------------------------------------------
-- Server version	5.0.51a

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
-- Table structure for table `adverse_event`
--

DROP TABLE IF EXISTS `adverse_event`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `adverse_event` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date default NULL,
  `notes` text,
  `severity_id` int(11) default NULL,
  `action_id` int(11) default NULL,
  `outcome_id` int(11) default NULL,
  `trial_related_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY (`patient_id`),
  KEY (`severity_id`),
  KEY (`action_id`),
  KEY (`outcome_id`),
  KEY (`trial_related_id`),
  CONSTRAINT `adverse_event_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`),
  CONSTRAINT `adverse_event_ibfk_2` FOREIGN KEY (`severity_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `adverse_event_ibfk_3` FOREIGN KEY (`action_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `adverse_event_ibfk_4` FOREIGN KEY (`outcome_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `adverse_event_ibfk_5` FOREIGN KEY (`trial_related_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `adverse_event`
--

LOCK TABLES `adverse_event` WRITE;
/*!40000 ALTER TABLE `adverse_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `adverse_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comorbidity`
--

DROP TABLE IF EXISTS `comorbidity`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `comorbidity` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `condition_name` varchar(255) NOT NULL,
  `date` date default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`patient_id`,`condition_name`,`date`),
  KEY (`patient_id`),
  CONSTRAINT `comorbidity_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `comorbidity`
--

LOCK TABLES `comorbidity` WRITE;
/*!40000 ALTER TABLE `comorbidity` DISABLE KEYS */;
/*!40000 ALTER TABLE `comorbidity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `controlled_vocab`
--

DROP TABLE IF EXISTS `controlled_vocab`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `controlled_vocab` (
  `id` int(11) NOT NULL auto_increment,
  `accession` varchar(31) NOT NULL,
  `category` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `term_source_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`accession`),
  UNIQUE KEY (`category`,`value`),
  KEY (`term_source_id`),
  CONSTRAINT `controlled_vocab_ibfk_1` FOREIGN KEY (`term_source_id`) REFERENCES `term_source` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `controlled_vocab`
--

LOCK TABLES `controlled_vocab` WRITE;
/*!40000 ALTER TABLE `controlled_vocab` DISABLE KEYS */;
/*!40000 ALTER TABLE `controlled_vocab` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `related_vocab`
--

DROP TABLE IF EXISTS `related_vocab`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `related_vocab` (
  `id` int(11) NOT NULL auto_increment,
  `controlled_vocab_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `relationship_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`controlled_vocab_id`,`target_id`,`relationship_id`),
  KEY (`controlled_vocab_id`),
  KEY (`target_id`),
  KEY (`relationship_id`),
  CONSTRAINT `related_vocab_ibfk_1` FOREIGN KEY (`controlled_vocab_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `related_vocab_ibfk_2` FOREIGN KEY (`target_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `related_vocab_ibfk_3` FOREIGN KEY (`relationship_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `related_vocab`
--

LOCK TABLES `related_vocab` WRITE;
/*!40000 ALTER TABLE `related_vocab` DISABLE KEYS */;
/*!40000 ALTER TABLE `related_vocab` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `term_source`
--

DROP TABLE IF EXISTS `term_source`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `term_source` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(31) NOT NULL,
  `version` varchar(31) default NULL,
  `uri` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `term_source`
--

LOCK TABLES `term_source` WRITE;
/*!40000 ALTER TABLE `term_source` DISABLE KEYS */;
/*!40000 ALTER TABLE `term_source` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diagnosis`
--

DROP TABLE IF EXISTS `diagnosis`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `diagnosis` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `condition_name_id` int(11) NOT NULL,
  `confidence_id` int(11) default NULL,
  `date` date default NULL,
  `previous_episodes` tinyint(1) default NULL,
  `previous_course_id` int(11) default NULL,
  `previous_duration_months` decimal(12,5) default NULL,
  `disease_staging_id` int(11) default NULL,
  `disease_extent_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`patient_id`, `condition_name_id`),
  KEY (`patient_id`),
  KEY (`condition_name_id`),
  KEY (`confidence_id`),
  KEY (`disease_staging_id`),
  KEY (`disease_extent_id`),
  CONSTRAINT `diagnosis_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`),
  CONSTRAINT `diagnosis_ibfk_2` FOREIGN KEY (`condition_name_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `diagnosis_ibfk_3` FOREIGN KEY (`confidence_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `diagnosis_ibfk_4` FOREIGN KEY (`previous_course_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `diagnosis_ibfk_5` FOREIGN KEY (`disease_staging_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `diagnosis_ibfk_6` FOREIGN KEY (`disease_extent_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `diagnosis`
--

LOCK TABLES `diagnosis` WRITE;
/*!40000 ALTER TABLE `diagnosis` DISABLE KEYS */;
/*!40000 ALTER TABLE `diagnosis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `study`
--

DROP TABLE IF EXISTS `study`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `study` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `external_id` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY (`patient_id`),
  KEY (`type_id`),
  CONSTRAINT `study_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`),
  CONSTRAINT `study_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `study`
--

LOCK TABLES `study` WRITE;
/*!40000 ALTER TABLE `study` DISABLE KEYS */;
/*!40000 ALTER TABLE `study` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `disease_event`
--

DROP TABLE IF EXISTS `disease_event`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `disease_event` (
  `id` int(11) NOT NULL auto_increment,
  `type_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `notes` text,
  PRIMARY KEY  (`id`),
  KEY (`type_id`),
  KEY (`patient_id`),
  CONSTRAINT `disease_event_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`),
  CONSTRAINT `disease_event_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `disease_event`
--

LOCK TABLES `disease_event` WRITE;
/*!40000 ALTER TABLE `disease_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `disease_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drug`
--

DROP TABLE IF EXISTS `drug`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `drug` (
  `id` int(11) NOT NULL auto_increment,
  `name_id` int(11) NOT NULL,
  `dose` decimal(12,5) default NULL,
  `dose_unit_id` int(11) default NULL,
  `dose_freq_id` int(11) default NULL,
  `dose_duration` decimal(12,5) default NULL,
  `duration_unit_id` int(11) default NULL,
  `dose_regime` varchar(255) default NULL,
  `locale_id` int(11) default NULL,
  `visit_id` int(11) default NULL,
  `prior_treatment_id` int(11) default NULL,
  `hospitalisation_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY (`name_id`),
  KEY (`locale_id`),
  KEY (`dose_unit_id`),
  KEY (`dose_freq_id`),
  KEY (`duration_unit_id`),
  KEY (`visit_id`),
  KEY (`prior_treatment_id`),
  KEY (`hospitalisation_id`),
  -- Only one instance of a given drug allowed per visit (or whatever).
  UNIQUE KEY (`name_id`, `visit_id`),
  UNIQUE KEY (`name_id`, `hospitalisation_id`),
  UNIQUE KEY (`name_id`, `prior_treatment_id`),
  CONSTRAINT `drug_ibfk_1` FOREIGN KEY (`dose_unit_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `drug_ibfk_2` FOREIGN KEY (`dose_freq_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `drug_ibfk_3` FOREIGN KEY (`name_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `drug_ibfk_4` FOREIGN KEY (`locale_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `drug_ibfk_5` FOREIGN KEY (`visit_id`) REFERENCES `visit` (`id`),
  CONSTRAINT `drug_ibfk_6` FOREIGN KEY (`prior_treatment_id`) REFERENCES `prior_treatment` (`id`),
  CONSTRAINT `drug_ibfk_7` FOREIGN KEY (`hospitalisation_id`) REFERENCES `hospitalisation` (`id`),
  CONSTRAINT `drug_ibfk_8` FOREIGN KEY (`duration_unit_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `risk_factor`
--

DROP TABLE IF EXISTS `risk_factor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `risk_factor` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `notes` text, 
  PRIMARY KEY  (`id`),
  KEY (`patient_id`),
  KEY (`type_id`),
  CONSTRAINT `risk_factor_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`),
  CONSTRAINT `risk_factor_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `risk_factor`
--

LOCK TABLES `risk_factor` WRITE;
/*!40000 ALTER TABLE `risk_factor` DISABLE KEYS */;
/*!40000 ALTER TABLE `risk_factor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `drug`
--

LOCK TABLES `drug` WRITE;
/*!40000 ALTER TABLE `drug` DISABLE KEYS */;
/*!40000 ALTER TABLE `drug` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emergent_group`
--

DROP TABLE IF EXISTS `emergent_group`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `emergent_group` (
  `id` int(11) NOT NULL auto_increment,
  `basis_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`name`,`type_id`),
  KEY (`basis_id`),
  KEY (`type_id`),
  CONSTRAINT `emergent_group_ibfk_1` FOREIGN KEY (`basis_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `emergent_group_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `emergent_group`
--

LOCK TABLES `emergent_group` WRITE;
/*!40000 ALTER TABLE `emergent_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `emergent_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prior_group`
--

DROP TABLE IF EXISTS `prior_group`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `prior_group` (
  `id` int(11) NOT NULL auto_increment,
  `type_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`name`,`type_id`),
  KEY (`type_id`),
  CONSTRAINT `prior_group_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `prior_group`
--

LOCK TABLES `prior_group` WRITE;
/*!40000 ALTER TABLE `prior_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `prior_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_involvement`
--

DROP TABLE IF EXISTS `system_involvement`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `system_involvement` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`patient_id`, `type_id`),
  KEY (`patient_id`),
  KEY (`type_id`),
  CONSTRAINT `system_involvement_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`) ON DELETE CASCADE,
  CONSTRAINT `system_involvement_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `system_involvement`
--

LOCK TABLES `system_involvement` WRITE;
/*!40000 ALTER TABLE `system_involvement` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_involvement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clinical_feature`
--

DROP TABLE IF EXISTS `clinical_feature`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `clinical_feature` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`patient_id`, `type_id`),
  KEY (`patient_id`),
  KEY (`type_id`),
  CONSTRAINT `clinical_feature_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`) ON DELETE CASCADE,
  CONSTRAINT `clinical_feature_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `clinical_feature`
--

LOCK TABLES `clinical_feature` WRITE;
/*!40000 ALTER TABLE `clinical_feature` DISABLE KEYS */;
/*!40000 ALTER TABLE `clinical_feature` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hospitalisation`
--

DROP TABLE IF EXISTS `hospitalisation`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `hospitalisation` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `days_duration` int(6) default NULL,
  `postop_days_duration` int(6) default NULL,
  `reason_for_admission` varchar(255) default NULL,
  `notes` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`patient_id`,`date`),    -- only one hosp per patient per date.
  CONSTRAINT `hospitalisation_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `hospitalisation`
--

LOCK TABLES `hospitalisation` WRITE;
/*!40000 ALTER TABLE `hospitalisation` DISABLE KEYS */;
/*!40000 ALTER TABLE `hospitalisation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient`
--

DROP TABLE IF EXISTS `patient`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `patient` (
  `id` int(11) NOT NULL auto_increment,
  `year_of_birth` year(4) default NULL,
  `sex` char(1) default NULL,
  `trial_id` varchar(15) NOT NULL,
  `ethnicity_id` int(11) default NULL,
  `home_centre_id` int(11) default NULL,
  `entry_date` date NOT NULL,
  `notes` text,
  PRIMARY KEY  (`id`),
  KEY (`ethnicity_id`),
  KEY (`home_centre_id`),
  UNIQUE KEY (`trial_id`),
  CONSTRAINT `patient_ibfk_1` FOREIGN KEY (`ethnicity_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `patient_ibfk_2` FOREIGN KEY (`home_centre_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `patient`
--

LOCK TABLES `patient` WRITE;
/*!40000 ALTER TABLE `patient` DISABLE KEYS */;
/*!40000 ALTER TABLE `patient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_prior_group`
--

DROP TABLE IF EXISTS `patient_prior_group`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `patient_prior_group` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `prior_group_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`patient_id`,`prior_group_id`),
  KEY (`patient_id`),
  KEY (`prior_group_id`),
  CONSTRAINT `patient_prior_group_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`) ON DELETE CASCADE,
  CONSTRAINT `patient_prior_group_ibfk_2` FOREIGN KEY (`prior_group_id`) REFERENCES `prior_group` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `patient_prior_group`
--

LOCK TABLES `patient_prior_group` WRITE;
/*!40000 ALTER TABLE `patient_prior_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `patient_prior_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visit_emergent_group`
--

DROP TABLE IF EXISTS `visit_emergent_group`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `visit_emergent_group` (
  `id` int(11) NOT NULL auto_increment,
  `visit_id` int(11) NOT NULL,
  `emergent_group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`visit_id`,`emergent_group_id`),
  KEY (`visit_id`),
  KEY (`emergent_group_id`),
  CONSTRAINT `visit_emergent_group_ibfk_1` FOREIGN KEY (`visit_id`) REFERENCES `visit` (`id`) ON DELETE CASCADE,
  CONSTRAINT `visit_emergent_group_ibfk_2` FOREIGN KEY (`emergent_group_id`) REFERENCES `emergent_group` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `visit_emergent_group`
--

LOCK TABLES `visit_emergent_group` WRITE;
/*!40000 ALTER TABLE `visit_emergent_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `visit_emergent_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prior_observation`
--

DROP TABLE IF EXISTS `prior_observation`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `prior_observation` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `value` varchar(255) default NULL,
  `date` date default NULL,
  PRIMARY KEY  (`id`),
  KEY (`type_id`),
  KEY (`patient_id`),
  CONSTRAINT `prior_observation_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `prior_observation_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `prior_observation`
--

LOCK TABLES `prior_observation` WRITE;
/*!40000 ALTER TABLE `prior_observation` DISABLE KEYS */;
/*!40000 ALTER TABLE `prior_observation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prior_treatment`
--

DROP TABLE IF EXISTS `prior_treatment`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `prior_treatment` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `value` varchar(255) default NULL,
  `notes` text default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`patient_id`, `type_id`),
  KEY (`patient_id`),
  KEY (`type_id`),
  CONSTRAINT `prior_treatment_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `prior_treatment_ibfk_4` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `prior_treatment`
--

LOCK TABLES `prior_treatment` WRITE;
/*!40000 ALTER TABLE `prior_treatment` DISABLE KEYS */;
/*!40000 ALTER TABLE `prior_treatment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `role` (
  `id` int(11) NOT NULL auto_increment,
  `rolename` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`rolename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sample`
--

DROP TABLE IF EXISTS `sample`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `sample` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(31) NOT NULL,
  `visit_id` int(11) NOT NULL,
  `cell_type_id` int(11) NOT NULL,
  `material_type_id` int(11) NOT NULL,
  `num_aliquots` int(6) default NULL,
  `freezer_location` varchar(255) default NULL,
  `freezer_box` varchar(31) default NULL,
  `box_slot` varchar(31) default NULL,
  `concentration` decimal(12,5) default NULL,
  `purity` decimal(12,5) default NULL,
  `cell_purity` decimal(12,5) default NULL,
  `quality_score_id` int(11) default NULL,
  `has_expired` tinyint(1) default NULL,
  `notes` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`name`),
--  UNIQUE KEY (`freezer_box`,`box_slot`),  -- Not available for some samples;
  KEY (`visit_id`),
  KEY (`cell_type_id`),
  KEY (`material_type_id`),
  KEY (`quality_score_id`),
  CONSTRAINT `sample_ibfk_1` FOREIGN KEY (`visit_id`) REFERENCES `visit` (`id`),
  CONSTRAINT `sample_ibfk_2` FOREIGN KEY (`cell_type_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `sample_ibfk_3` FOREIGN KEY (`material_type_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `sample_ibfk_4` FOREIGN KEY (`quality_score_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `sample`
--

LOCK TABLES `sample` WRITE;
/*!40000 ALTER TABLE `sample` DISABLE KEYS */;
/*!40000 ALTER TABLE `sample` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sample_data_file`
--

DROP TABLE IF EXISTS `sample_data_file`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `sample_data_file` (
  `id` int(11) NOT NULL auto_increment,
  `sample_id` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `type_id` int(11) NOT NULL,
  `notes` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`filename`),
  KEY (`sample_id`),
  KEY (`type_id`),
  CONSTRAINT `sample_data_file_ibfk_1` FOREIGN KEY (`sample_id`) REFERENCES `sample` (`id`),
  CONSTRAINT `sample_data_file_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `sample_data_file`
--

LOCK TABLES `sample_data_file` WRITE;
/*!40000 ALTER TABLE `sample_data_file` DISABLE KEYS */;
/*!40000 ALTER TABLE `sample_data_file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visit_data_file`
--

DROP TABLE IF EXISTS `visit_data_file`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `visit_data_file` (
  `id` int(11) NOT NULL auto_increment,
  `visit_id` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `type_id` int(11) NOT NULL,
  `notes` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`filename`),
  KEY (`visit_id`),
  KEY (`type_id`),
  CONSTRAINT `visit_data_file_ibfk_1` FOREIGN KEY (`visit_id`) REFERENCES `visit` (`id`),
  CONSTRAINT `visit_data_file_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `visit_data_file`
--

LOCK TABLES `visit_data_file` WRITE;
/*!40000 ALTER TABLE `visit_data_file` DISABLE KEYS */;
/*!40000 ALTER TABLE `visit_data_file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phenotype_quantity`
--

DROP TABLE IF EXISTS `phenotype_quantity`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `phenotype_quantity` (
  `id` int(11) NOT NULL auto_increment,
  `visit_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `value` decimal(12,5) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`visit_id`,`type_id`),
  KEY (`visit_id`),
  KEY (`type_id`),
  CONSTRAINT `phenotype_quantity_ibfk_1` FOREIGN KEY (`visit_id`) REFERENCES `visit` (`id`),
  CONSTRAINT `phenotype_quantity_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `phenotype_quantity`
--

LOCK TABLES `phenotype_quantity` WRITE;
/*!40000 ALTER TABLE `phenotype_quantity` DISABLE KEYS */;
/*!40000 ALTER TABLE `phenotype_quantity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assay_batch`
--

DROP TABLE IF EXISTS `assay_batch`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `assay_batch` (
  `id` int(11) NOT NULL auto_increment,
  `date` date NOT NULL,
  `name` varchar(31) NOT NULL,
  `operator` varchar(255) default NULL,
  `platform_id` int(11) NOT NULL,
  `notes` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`name`),
  CONSTRAINT `assay_batch_ibfk_1` FOREIGN KEY (`platform_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `assay_batch`
--

LOCK TABLES `assay_batch` WRITE;
/*!40000 ALTER TABLE `assay_batch` DISABLE KEYS */;
/*!40000 ALTER TABLE `assay_batch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assay`
--

DROP TABLE IF EXISTS `assay`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `assay` (
  `id` int(11) NOT NULL auto_increment,
  `identifier` varchar(255) NOT NULL,
  `assay_batch_id` int(11) NOT NULL,
  `filename` varchar(255) default NULL,
  `notes` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`identifier`),
  UNIQUE KEY (`filename`),
  KEY (`assay_batch_id`),
  CONSTRAINT `assay_ibfk_1` FOREIGN KEY (`assay_batch_id`) REFERENCES `assay_batch` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `assay`
--

LOCK TABLES `assay` WRITE;
/*!40000 ALTER TABLE `assay` DISABLE KEYS */;
/*!40000 ALTER TABLE `assay` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assay_qc_value`
--

DROP TABLE IF EXISTS `assay_qc_value`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `assay_qc_value` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `type` varchar(255) default NULL,
  `assay_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`name`,`assay_id`),
  KEY (`assay_id`),
  CONSTRAINT `assay_qc_value_ibfk_1` FOREIGN KEY (`assay_id`) REFERENCES `assay` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `assay_qc_value`
--

LOCK TABLES `assay_qc_value` WRITE;
/*!40000 ALTER TABLE `assay_qc_value` DISABLE KEYS */;
/*!40000 ALTER TABLE `assay_qc_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channel`
--

DROP TABLE IF EXISTS `channel`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `channel` (
  `id` int(11) NOT NULL auto_increment,
  `label_id` int(11) NOT NULL,
  `sample_id` int(11) NOT NULL,
  `assay_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY (`label_id`),
  KEY (`sample_id`),
  KEY (`assay_id`),
  UNIQUE KEY (`assay_id`,`label_id`),
  CONSTRAINT `channel_ibfk_1` FOREIGN KEY (`label_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `channel_ibfk_2` FOREIGN KEY (`sample_id`) REFERENCES `sample` (`id`) ON DELETE CASCADE,
  CONSTRAINT `channel_ibfk_3` FOREIGN KEY (`assay_id`) REFERENCES `assay` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `channel`
--

LOCK TABLES `channel` WRITE;
/*!40000 ALTER TABLE `channel` DISABLE KEYS */;
/*!40000 ALTER TABLE `channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test`
--

DROP TABLE IF EXISTS `test`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `test` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `test`
--

LOCK TABLES `test` WRITE;
/*!40000 ALTER TABLE `test` DISABLE KEYS */;
/*!40000 ALTER TABLE `test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test_aggregation`
--

DROP TABLE IF EXISTS `test_aggregation`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `test_aggregation` (
  `id` int(11) NOT NULL auto_increment,
  `aggregate_result_id` int(11) NOT NULL,
  `test_result_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`aggregate_result_id`,`test_result_id`),
  KEY (`aggregate_result_id`),
  KEY (`test_result_id`),
  CONSTRAINT `test_aggregation_ibfk_1` FOREIGN KEY (`aggregate_result_id`) REFERENCES `test_result` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `test_aggregation_ibfk_2` FOREIGN KEY (`test_result_id`) REFERENCES `test_result` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `test_aggregation`
--

LOCK TABLES `test_aggregation` WRITE;
/*!40000 ALTER TABLE `test_aggregation` DISABLE KEYS */;
/*!40000 ALTER TABLE `test_aggregation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test_possible_value`
--

DROP TABLE IF EXISTS `test_possible_value`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `test_possible_value` (
  `id` int(11) NOT NULL auto_increment,
  `test_id` int(11) NOT NULL,
  `possible_value_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`test_id`,`possible_value_id`),
  KEY (`test_id`),
  KEY (`possible_value_id`),
  CONSTRAINT `test_possible_value_ibfk_1` FOREIGN KEY (`test_id`) REFERENCES `test` (`id`) ON DELETE CASCADE,
  CONSTRAINT `test_possible_value_ibfk_2` FOREIGN KEY (`possible_value_id`) REFERENCES `controlled_vocab` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `test_possible_value`
--

LOCK TABLES `test_possible_value` WRITE;
/*!40000 ALTER TABLE `test_possible_value` DISABLE KEYS */;
/*!40000 ALTER TABLE `test_possible_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test_result`
--

DROP TABLE IF EXISTS `test_result`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `test_result` (
  `id` int(11) NOT NULL auto_increment,
  `test_id` int(11) NOT NULL,
  `visit_id` int(11) default NULL,
  `hospitalisation_id` int(11) default NULL,
  `value` varchar(255) default NULL,
  `controlled_value_id` int(11) default NULL,
  `date` date NOT NULL,
  `needs_reparenting` tinyint(1) default NULL, 
  PRIMARY KEY  (`id`),
  KEY (`test_id`),
  KEY (`visit_id`),
  KEY (`hospitalisation_id`),
  KEY (`controlled_value_id`),
  UNIQUE KEY (`test_id`, `date`, `visit_id`),
  UNIQUE KEY (`test_id`, `date`, `hospitalisation_id`),
  CONSTRAINT `test_result_ibfk_1` FOREIGN KEY (`test_id`) REFERENCES `test` (`id`),
  CONSTRAINT `test_result_ibfk_2` FOREIGN KEY (`visit_id`) REFERENCES `visit` (`id`),
  CONSTRAINT `test_result_ibfk_3` FOREIGN KEY (`hospitalisation_id`) REFERENCES `hospitalisation` (`id`),
  CONSTRAINT `test_result_ibfk_4` FOREIGN KEY (`controlled_value_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `test_result`
--

LOCK TABLES `test_result` WRITE;
/*!40000 ALTER TABLE `test_result` DISABLE KEYS */;
/*!40000 ALTER TABLE `test_result` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transplant`
--

DROP TABLE IF EXISTS `transplant`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `transplant` (
  `id` int(11) NOT NULL auto_increment,
  `hospitalisation_id` int(11) NOT NULL,
  `date` date default NULL,
  `number` int(6) default NULL,
  `sensitisation_status_id` int(11) default NULL,
  `recip_cmv` tinyint(1) default NULL,
  `delayed_graft_function` tinyint(1) default NULL,
  `days_delayed_function` int(6) default NULL,
  `organ_type_id` int(11) NOT NULL,
  `mins_cold_ischaemic` int(6) default NULL,
  `reperfusion_quality_id` int(11) default NULL,
  `hla_mismatch` varchar(255) default NULL,
  `donor_type_id` int(11) NOT NULL,
  `donor_age` int(3) default NULL,
  `donor_cause_of_death` varchar(255) default NULL,
  `donor_cmv` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`hospitalisation_id`, `date`),
  KEY (`hospitalisation_id`),
  KEY (`sensitisation_status_id`),
  KEY (`organ_type_id`),
  KEY (`reperfusion_quality_id`),
  KEY (`donor_type_id`),
  CONSTRAINT `transplant_ibfk_1` FOREIGN KEY (`hospitalisation_id`) REFERENCES `hospitalisation` (`id`),
  CONSTRAINT `transplant_ibfk_2` FOREIGN KEY (`sensitisation_status_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `transplant_ibfk_3` FOREIGN KEY (`organ_type_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `transplant_ibfk_4` FOREIGN KEY (`reperfusion_quality_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `transplant_ibfk_5` FOREIGN KEY (`donor_type_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `transplant`
--

LOCK TABLES `transplant` WRITE;
/*!40000 ALTER TABLE `transplant` DISABLE KEYS */;
/*!40000 ALTER TABLE `transplant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `user` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) NOT NULL,
  `name` varchar(255),
  `email` varchar(255),
  `password` varchar(40) NOT NULL,    -- The length of a Digest->hexdigest string.
  `date_created` datetime NOT NULL,
  `date_modified` datetime,
  `date_accessed` datetime,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_role`
--

DROP TABLE IF EXISTS `user_role`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `user_role` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`user_id`,`role_id`),
  KEY (`user_id`),
  KEY (`role_id`),
  CONSTRAINT `user_role_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_role_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `user_role`
--

LOCK TABLES `user_role` WRITE;
/*!40000 ALTER TABLE `user_role` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visit`
--

DROP TABLE IF EXISTS `visit`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `visit` (
  `id` int(11) NOT NULL auto_increment,
  `date` date NOT NULL,
  `notes` text,
  `disease_activity_id` int(11) default NULL,
  `patient_id` int(11) NOT NULL,
  `nominal_timepoint_id` int(11) default NULL,
  `treatment_escalation` tinyint(1) default NULL,
  `has_infection` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`patient_id`,`date`),
  KEY (`patient_id`),
  KEY (`disease_activity_id`),
  KEY (`nominal_timepoint_id`),
  CONSTRAINT `visit_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`),
  CONSTRAINT `visit_ibfk_2` FOREIGN KEY (`disease_activity_id`) REFERENCES `controlled_vocab` (`id`),
  CONSTRAINT `visit_ibfk_3` FOREIGN KEY (`nominal_timepoint_id`) REFERENCES `controlled_vocab` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `visit`
--

LOCK TABLES `visit` WRITE;
/*!40000 ALTER TABLE `visit` DISABLE KEYS */;
/*!40000 ALTER TABLE `visit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `graft_failure`
--

DROP TABLE IF EXISTS `graft_failure`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `graft_failure` (
  `id` int(11) NOT NULL auto_increment,
  `date` date NOT NULL,
  `reason` varchar(255),
  `notes` text,
  `transplant_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY (`transplant_id`),
  CONSTRAINT `graft_failure_ibfk_1` FOREIGN KEY (`transplant_id`) REFERENCES `transplant` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `graft_failure`
--

LOCK TABLES `graft_failure` WRITE;
/*!40000 ALTER TABLE `graft_failure` DISABLE KEYS */;
/*!40000 ALTER TABLE `graft_failure` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;



/* Create some basic triggers to enforce drug and test_result linking
   to only one container. These are somewhat lame, but are apparently
   the best that MySQL version 5.0 can muster. Fix the 'set' statements
   to proper error raising when MySQL 6.1 is finally available */

delimiter //

/* Triggers to make sure that Drugs are always attached to one only of
   Visit, Hospitalisation or PriorTreatment */
drop trigger if exists `drug_update_trigger`//
create trigger `drug_update_trigger`
    before update on drug
for each row
begin
    if ( (new.visit_id is not null)
       + (new.hospitalisation_id is not null)
       + (new.prior_treatment_id is not null) != 1) then
        call ERROR_DRUG_UPDATE_TRIGGER();
    end if;
end;
//

drop trigger if exists `drug_insert_trigger`//
create trigger `drug_insert_trigger`
    before insert on drug
for each row
begin
    if ( (new.visit_id is not null)
       + (new.hospitalisation_id is not null)
       + (new.prior_treatment_id is not null) != 1) then
        call ERROR_DRUG_INSERT_TRIGGER();
    end if;
end;
//

/* Triggers to ensure that test_results conform to
   value/controlled_value_id rules for uncontrolled tests and those
   with a set of test_possible_value. */
drop trigger if exists `test_result_value_insert_trigger`//
create trigger `test_result_value_insert_trigger`
    before insert on test_result
for each row
begin
    if ( (new.visit_id is not null)
       + (new.hospitalisation_id is not null) != 1) then
        call ERROR_TEST_RESULT_INSERT_TRIGGER();
    end if;
    if ( new.value is not null
       and (select count(possible_value_id)
            from test_possible_value
            where test_id=new.test_id) != 0 ) then
        call ERROR_TEST_RESULT_VALUE_INSERT_TRIGGER();
    end if;
    if ( new.controlled_value_id is not null
       and (select count(possible_value_id)
            from test_possible_value
            where test_id=new.test_id
            and possible_value_id=new.controlled_value_id) = 0 ) then
        call ERROR_TEST_RESULT_CONTROLLED_VALUE_INSERT_TRIGGER();
    end if;
end;
//

drop trigger if exists `test_result_value_update_trigger`//
create trigger `test_result_value_update_trigger`
    before update on test_result
for each row
begin
    if ( (new.visit_id is not null)
       + (new.hospitalisation_id is not null) != 1) then
        call ERROR_TEST_RESULT_UPDATE_TRIGGER();
    end if;
    if ( new.value is not null
        and (select count(possible_value_id)
             from test_possible_value
             where test_id=new.test_id) != 0 ) then
        call ERROR_TEST_RESULT_VALUE_UPDATE_TRIGGER();
    end if;
    if ( new.controlled_value_id is not null
        and (select count(possible_value_id)
             from test_possible_value where
             test_id=new.test_id
             and possible_value_id=new.controlled_value_id) = 0 ) then
        call ERROR_TEST_RESULT_CONTROLLED_VALUE_UPDATE_TRIGGER();
    end if;
end;
//

/* Triggers to make sure we don't inadvertently change a controlled
   test into uncontrolled, or vice versa, once we've started adding
   test results to it. Note that it is still possible to remove unused
   test_possible_value from a controlled value test */
drop trigger if exists `test_possible_value_insert_trigger`//
create trigger `test_possible_value_insert_trigger`
    before insert on test_possible_value
for each row
begin
    if ( (select count(value)
          from test_result
          where test_id=new.test_id
          and value is not null) != 0 ) then
        call ERROR_TEST_POSSIBLE_VALUE_INSERT_TRIGGER();
    end if;
end;
//

drop trigger if exists `test_possible_value_update_trigger`//
create trigger `test_possible_value_update_trigger`
    before update on test_possible_value
for each row
begin
    if ( (select count(value)
          from test_result
          where test_id=new.test_id
          and value is not null) != 0 ) then
        call ERROR_TEST_POSSIBLE_VALUE_UPDATE_TRIGGER();
    end if;
end;
//

drop trigger if exists `test_possible_value_delete_trigger`//
create trigger `test_possible_value_delete_trigger`
    before delete on test_possible_value
for each row
begin
    if ( (select count(controlled_value_id)
          from test_result
          where test_id=old.test_id
          and controlled_value_id=old.possible_value_id) != 0 ) then
        call ERROR_TEST_POSSIBLE_VALUE_DELETE_TRIGGER();
    end if;
end;
//

/* End of triggers */
delimiter ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-08-29 13:06:07
