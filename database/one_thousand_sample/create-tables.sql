CREATE TABLE IF NOT EXISTS phenopacket_v1
(
    id SERIAL PRIMARY KEY,
    json_data JSONB
);

CREATE TABLE IF NOT EXISTS one_thousand_genomes_sample
(
    id SERIAL PRIMARY KEY,
    json_data JSONB
);
