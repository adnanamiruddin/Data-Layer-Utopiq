CREATE SCHEMA belajar;

SET search_path TO belajar;
--
SHOW search_path;

CREATE TABLE belajar.produk (
	id SERIAL PRIMARY KEY,
	nama TEXT,
	harga NUMERIC
);

INSERT INTO produk(nama, harga)
	VALUES
		('Espresso', 20000),
		('Latte', 25000);

SELECT * FROM produk;

-- Buat tabel yang mencatat perubahan harga
CREATE TABLE belajar.log_harga (
	id SERIAL PRIMARY KEY,
	produk_id INT,
	harga_lama NUMERIC,
	harga_baru NUMERIC,
	waktu TIMESTAMP
);

-- Buat trigger function
CREATE OR REPLACE FUNCTION belajar.log_perubahan_harga()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF NEW.harga <> OLD.harga
		THEN INSERT INTO belajar.log_harga(produk_id, harga_lama, harga_baru, waktu)
				VALUES (OLD.id, OLD.harga, NEW.harga, NOW());
	END IF;
	RETURN NEW;
END;
$$;

-- Buat trigger yang akan ter-trigger ketika ada update di tabel produk
CREATE OR REPLACE TRIGGER trigger_log_harga
AFTER UPDATE ON belajar.produk
FOR EACH ROW
EXECUTE FUNCTION log_perubahan_harga();

SELECT *
FROM information_schema.triggers;

-- Tes Trigger-nya
SELECT * FROM belajar.log_harga;

UPDATE belajar.produk
SET nama='Matcha Latte', harga=40000
WHERE id=2;

UPDATE belajar.produk
SET harga=21000
WHERE id=1;









