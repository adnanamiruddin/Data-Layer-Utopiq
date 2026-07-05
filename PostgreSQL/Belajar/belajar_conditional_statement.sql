CREATE OR REPLACE client_min_messages TO NOTICE;
DO $$
DECLARE
	score INT := 80;
BEGIN
	IF score >= 75 THEN
		RAISE NOTICE 'Lulus';
	ELSE
		RAISE NOTICE 'Tidak Lulus';
	END IF;
END $$;