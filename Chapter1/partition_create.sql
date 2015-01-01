DELIMITER $$
CREATE PROCEDURE `partition_create`(SCHEMANAME VARCHAR(64), TABLENAME VARCHAR(64), PARTITIONNAME VARCHAR(64), CLOCK INT)
BEGIN
        /*
           SCHEMANAME = The DB schema in which to make changes
           TABLENAME = The table with partitions to potentially delete
           PARTITIONNAME = The name of the partition to create
        */
        /*
           Verify that the partition does not already exist
        */
 
        DECLARE RETROWS INT;
        SELECT COUNT(1) INTO RETROWS
        FROM information_schema.partitions
        WHERE table_schema = SCHEMANAME AND TABLE_NAME = TABLENAME AND partition_name = PARTITIONNAME;
 
        IF RETROWS = 0 THEN
                /*
                   1. Print a message indicating that a partition was created.
                   2. Create the SQL to create the partition.
                   3. Execute the SQL from #2.
                */
                SELECT CONCAT( "partition_create(", SCHEMANAME, ",", TABLENAME, ",", PARTITIONNAME, ",", CLOCK, ")" ) AS msg;
                SET @SQL = CONCAT( 'ALTER TABLE ', SCHEMANAME, '.', TABLENAME, ' ADD PARTITION (PARTITION ', PARTITIONNAME, ' VALUES LESS THAN (', CLOCK, '));' );
                PREPARE STMT FROM @SQL;
                EXECUTE STMT;
                DEALLOCATE PREPARE STMT;
        END IF;
END$$
DELIMITER ;
