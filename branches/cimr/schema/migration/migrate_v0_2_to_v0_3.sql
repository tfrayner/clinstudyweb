-- Upgrade script to handle migration of database schema adding term_source table and accoutrements.
--
-- Table structure for table `term_source`
--

DROP TABLE IF EXISTS `term_source`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `term_source` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(31) NOT NULL,
  `version` varchar(31) DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `term_source_audit_history`
--

DROP TABLE IF EXISTS `term_source_audit_history`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `term_source_audit_history` (
  `audit_history_id` int(11) NOT NULL AUTO_INCREMENT,
  `audit_change_id` int(11) NOT NULL,
  `id` int(11) DEFAULT NULL,
  `name` varchar(31) DEFAULT NULL,
  `version` varchar(31) DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`audit_history_id`),
  KEY `term_source_audit_history_idx_audit_change_id` (`audit_change_id`),
  CONSTRAINT `term_source_audit_history_fk_audit_change_id` FOREIGN KEY (`audit_change_id`) REFERENCES `changelog` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
 SET character_set_client = @saved_cs_client;
 
--
-- Table structure for table `term_source_audit_log`
--

DROP TABLE IF EXISTS `term_source_audit_log`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `term_source_audit_log` (
  `create_id` int(11) NOT NULL,
  `delete_id` int(11) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `term_source_audit_log_idx_create_id` (`create_id`),
  KEY `term_source_audit_log_idx_delete_id` (`delete_id`),
  CONSTRAINT `term_source_audit_log_fk_create_id` FOREIGN KEY (`create_id`) REFERENCES `changelog` (`ID`),
  CONSTRAINT `term_source_audit_log_fk_delete_id` FOREIGN KEY (`delete_id`) REFERENCES `changelog` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure update for table `controlled_vocab` and its audit_history table.
--
ALTER TABLE controlled_vocab ADD COLUMN `term_source_id` int(11) DEFAULT NULL;
ALTER TABLE controlled_vocab ADD KEY `term_source_id` (`term_source_id`);
ALTER TABLE controlled_vocab ADD CONSTRAINT `controlled_vocab_ibfk_1` FOREIGN KEY (`term_source_id`) REFERENCES `term_source` (`id`);
 
ALTER TABLE controlled_vocab_audit_history ADD COLUMN `term_source_id` int(11) DEFAULT NULL;
 
