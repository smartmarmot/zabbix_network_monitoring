DELIMITER $$
CREATE PROCEDURE `partition_verify`(SCHEMANAME VARCHAR(64), TABLENAME VARCHAR(64), HOURLYINTERVAL INT(11))
BEGIN
        DECLARE PARTITION_NAME VARCHAR(16);
        DECLARE RETROWS INT(11);
        DECLARE FUTURE_TIMESTAMP TIMESTAMP;
 
        /*
         * Check if any partitions exist for the given SCHEMANAME.TABLENAME.
         */
        SELECT COUNT(1) INTO RETROWS
        FROM information_schema.partitions
        WHERE table_schema = SCHEMANAME AND TABLE_NAME = TABLENAME AND partition_name IS NULL;
 
        /*
         * If partitions do not exist, go ahead and partition the table
         */
        IF RETROWS = 1 THEN
                /*
                 * Take the current date at 00:00:00 and add HOURLYINTERVAL to it.  This is the timestamp below which we will store values.
                 * We begin partitioning based on the beginning of a day.  This is because we don't want to generate a random partition
                 * that won't necessarily fall in line with the desired partition naming (ie: if the hour interval is 24 hours, we could
                 * end up creating a partition now named "p201403270600" when all other partitions will be like "p201403280000").
                 */
                SET FUTURE_TIMESTAMP = TIMESTAMPADD(HOUR, HOURLYINTERVAL, CONCAT(CURDATE(), " ", '00:00:00'));
                SET PARTITION_NAME = DATE_FORMAT(CURDATE(), 'p%Y%m%d%H00');
 
                -- Create the partitioning query
                SET @__PARTITION_SQL = CONCAT("ALTER TABLE ", SCHEMANAME, ".", TABLENAME, " PARTITION BY RANGE(`clock`)");
                SET @__PARTITION_SQL = CONCAT(@__PARTITION_SQL, "(PARTITION ", PARTITION_NAME, " VALUES LESS THAN (", UNIX_TIMESTAMP(FUTURE_TIMESTAMP), "));");
 
                -- Run the partitioning query
                PREPARE STMT FROM @__PARTITION_SQL;
                EXECUTE STMT;
                DEALLOCATE PREPARE STMT;
        END IF;
END$$
DELIMITER ;
